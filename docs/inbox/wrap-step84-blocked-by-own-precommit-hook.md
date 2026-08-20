---
status: Open
filed: 2026-08-20
from: treeclusion
summary: wrap Step 8.4 mandates editing .shmorch/AGENTS.md inline, but the skill's own pre-commit hook template blocks committing anything outside docs/project/ directly to main — every wrap on main ends with a dirty working tree.
---

↑ [inbox/](index.md)

# wrap Step 8.4 is blocked by the skill's own pre-commit hook

## What happened

Running `/shmorch wrap` on `main` in treeclusion (2026-08-20):

- **Step 8.4** says: update the Current State section in `.shmorch/AGENTS.md` with today's date,
  integration branch, and test count — "Three fields; do it inline without asking."
- **Step 8.5** then commits state files via `tools/commit-session-state.sh`.
- The pre-commit hook from `templates/.githooks/pre-commit` rejects the commit:

  ```
  BLOCKED: direct commit to 'main'
  Code changes must land via PR from a feature branch.
  (State files — docs/project/, decisions/ — may commit directly.)
  ```

  `.shmorch/AGENTS.md` is not under `docs/project/` or `decisions/`, so it counts as a "code
  change." Step 8.4's edit cannot be committed by Step 8.5.

The result is that wrap — whose stated purpose is "so the working tree is clean at next session
start" — reliably ends with `.shmorch/AGENTS.md` modified and uncommitted, every session, on any
project that uses both the hook and the main-as-integration-branch setup. `commit-session-state.sh`
also doesn't flag it: it committed the two files it recognized and printed "Session state
committed," which reads as success.

## Why it matters

It's a self-inflicted contradiction between two skill files, so it reproduces in every project
that installs both. It also trains the wrong reflex — the natural workaround is to cut a branch
and open a PR for a two-line date stamp, which is a lot of ceremony, or to leave the tree dirty,
which quietly defeats the point of Step 8.5.

## Candidate fixes (not decided)

1. **Widen the hook's allowlist** to include `.shmorch/` — it is state, not code, and the hook
   already carves out state paths. Simplest, and consistent with the hook's own stated intent.
2. **Move Current State out of `.shmorch/AGENTS.md`** into a `docs/project/` file that AGENTS.md
   imports or references. Keeps the hook strict; costs an indirection.
3. **Have Step 8.5 detect the block** and either stage `.shmorch/AGENTS.md` onto a branch or tell
   the user explicitly, rather than reporting success while leaving the file dirty.

(1) looks right — Current State is exactly the kind of session bookkeeping the hook's carve-out
already exists for. But this is the skill's own security-ish guard, so it should be a deliberate
call rather than a quiet widening.

## Related

Same project previously filed `dead-link-scan-after-folder-moves.md` — also a case of one skill
tool leaving state the rest of the skill assumes is consistent.
