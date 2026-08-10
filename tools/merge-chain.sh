#!/usr/bin/env bash
# merge-chain.sh — deterministic merge -> pull -> rebase -> repeat for a stack of PRs
# Usage: bash tools/merge-chain.sh <remote> <PR#> [<PR#> ...]
#
# Encodes core/git-discipline.md's mandatory post-merge sequence as a script instead of
# relying on the agent remembering to run it by hand for every PR in a stack. Never squashes
# (uses `gh pr merge --merge`, per git-discipline.md's "never squash" default).
#
# For each PR #N in order:
#   1. gh pr merge N --merge
#   2. git checkout main && git pull <remote> main
#   3. If there's a next PR: check out its branch, rebase onto main.
#      - Clean rebase -> force-push (--force-with-lease) automatically.
#      - Conflict -> stop here. Resolve manually (VERSION conflicts: take main's value,
#        apply this branch's own bump tier on top — never move a tier backwards), commit,
#        force-push, then re-run this script starting from the NEXT PR in the list.
set -euo pipefail

REMOTE="${1:?usage: merge-chain.sh <remote> <PR#> [<PR#> ...]}"
shift
PRS=("$@")
[ "${#PRS[@]}" -ge 1 ] || { echo "usage: merge-chain.sh <remote> <PR#> [<PR#> ...]"; exit 1; }

for i in "${!PRS[@]}"; do
  PR="${PRS[$i]}"
  echo "=== [$((i+1))/${#PRS[@]}] Merging PR #$PR ==="
  gh pr merge "$PR" --merge

  git checkout main
  git pull "$REMOTE" main
  echo "=== main updated after PR #$PR ==="

  NEXT_I=$((i+1))
  if [ "$NEXT_I" -lt "${#PRS[@]}" ]; then
    NEXT_PR="${PRS[$NEXT_I]}"
    BRANCH="$(gh pr view "$NEXT_PR" --json headRefName -q .headRefName)"
    echo "=== Rebasing next branch '$BRANCH' (PR #$NEXT_PR) onto main ==="
    git checkout "$BRANCH"
    if git rebase main; then
      git push --force-with-lease "$REMOTE" "$BRANCH"
      echo "=== '$BRANCH' rebased and pushed cleanly ==="
    else
      cat <<EOF

=== REBASE CONFLICT on '$BRANCH' (PR #$NEXT_PR) ===
Resolve manually, then:
  git push --force-with-lease $REMOTE $BRANCH
  bash $(basename "$0") $REMOTE ${PRS[*]:$NEXT_I}

(VERSION conflicts: take main's current value, apply this branch's own bump tier on top —
never move a tier backwards. See core/git-discipline.md.)
EOF
      exit 1
    fi
    git checkout main
  fi
done

echo "=== Merge chain complete: ${#PRS[@]} PR(s) merged ==="
