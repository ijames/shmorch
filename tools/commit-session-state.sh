#!/usr/bin/env bash
# Commit end-of-session state files with a conventional commit message.
# Stages only the standard set of state files that exist and are modified.
# Safe to call on a clean tree — exits with "Nothing to commit." if nothing changed.
#
# Co-author trailer uses $SHMORCH_MODEL env var (default: Claude Sonnet 4.6).
# To update for a new model: export SHMORCH_MODEL="Claude Sonnet 4.7"
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if [ ! -d ".git" ]; then
  echo "Not a git repo."
  exit 1
fi

STATE_FILES=(
  docs/project/session.md
  docs/project/timelog.md
  .shmorch/AGENTS.md
)

for f in "${STATE_FILES[@]}"; do
  [ -f "$f" ] && git add "$f" 2>/dev/null || true
done

[ -d docs/project/plan ] && git add docs/project/plan 2>/dev/null || true

for d in docs/product/decisions docs/technology/decisions; do
  [ -d "$d" ] && git add "$d" 2>/dev/null || true
done

while IFS= read -r -d '' f; do
  git add "$f" 2>/dev/null || true
done < <(find docs/project -name 'self-improve-*.md' -print0 2>/dev/null)

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

MODEL="${SHMORCH_MODEL:-Claude Sonnet 4.6}"
git commit -m "$(cat <<EOF
chore(state): update session state

Co-Authored-By: $MODEL <noreply@anthropic.com>
EOF
)"
echo "Session state committed."
