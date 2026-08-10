---
status: Active
updated: 2026-08-10
summary: New `tools/merge-chain.sh` — scripts the merge->pull->rebase->repeat PR-stack sequence that git-discipline.md already documented in prose but which kept getting skipped mid-session.
---

↑ [core/operations.md](../../../../core/operations.md)
→ [core/git-discipline.md](../../../../core/git-discipline.md)

# Track: Deterministic merge-chain tool

**Status:** Active
**Started:** 2026-08-10
**Domain:** shmorch skill infrastructure (git tooling)

## Why

`core/git-discipline.md` already documented the required sequence for merging a stack of
PRs (merge → pull main → rebase next branch → repeat), but the user reported it's been
skipped repeatedly in practice — prose discipline isn't reliable when it depends on an agent
remembering a multi-step sequence mid-session, especially across a long session with other
work interleaved.

## What changed

- **`tools/merge-chain.sh`** — new script, `bash tools/merge-chain.sh <remote> <PR#> [...]`.
  For each PR in order: merges it (`gh pr merge --merge`, never squash — matches the existing
  "never squash" default), checks out and pulls main, then rebases the *next* PR's branch
  onto the fresh main. Clean rebase → force-push automatically. Conflict → stops with the
  exact resume command (re-run from the remaining PR list) and a reminder of the VERSION
  conflict rule (take main's value, apply this branch's own bump tier, never move a tier
  backwards) — conflict resolution stays a judgment call, not something the script guesses.
- **`core/git-discipline.md`** — added a pointer to the script right after the sequence
  diagram it was already skipping, framed as "use the tool, not memory."

## Not in scope

- No automatic conflict resolution — VERSION and other conflicts still need a human/agent
  decision per the existing rule; the script surfaces them clearly instead of resolving them.
- No change to the underlying merge strategy or branch cap rules — this only mechanizes the
  sequence that was already policy.
