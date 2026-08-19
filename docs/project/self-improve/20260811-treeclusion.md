### Self-Improve Proposals — 2026-08-11 | Project: treeclusion

#### Proposal 1: Fix stale path exemptions in .githooks pre-commit guard
**Pattern:** The `.githooks/pre-commit` (or equivalent) hook blocks direct commits to `main`/`dev` unless every staged file matches an exemption list. That list still reads `docs/state/` and `docs/development/decisions.md` — both renamed on 2026-07-24 to `docs/project/` and `docs/technology/decisions/` respectively. This session's `commit-session-state.sh` run tried to commit `docs/project/session.md` + `docs/project/timelog.md` on `main` and was BLOCKED, forcing a manual branch (`chore/20260811-wrap-state`) as a workaround.
**Frequency:** Observed once directly this session, but the root cause (stale rename) is structural — it will recur on every wrap session that runs `commit-session-state.sh` from `main`/`dev` until the hook is fixed.
**File:** `.githooks/pre-commit` (or wherever the block lives in this repo)
**Change:** Update the exemption grep patterns:
```diff
- -e '^docs/state/' \
- -e '^docs/development/decisions\.md' \
+ -e '^docs/project/' \
+ -e '^docs/technology/decisions/' \
+ -e '^docs/product/decisions/' \
```
Also update the echoed help text ("State files — docs/state/, decisions.md — may commit directly.") to match.
**Improvement:** `commit-session-state.sh` can commit state files directly to `main` again as originally intended, instead of every wrap session needing a throwaway `chore/*-wrap-state` branch + PR just to persist session.md/timelog.md.

### Already addressed
None found — this is the first self-improve pass since the 2026-07-24 taxonomy rename.

### No-action observations
- AskUserQuestion answer-mismatch handling (free-text reply to a multiple-choice question, correctly treated as a clarification request) — seen once, sound behavior, not a friction pattern.

### Inbox cleanup — 2026-08-11
Removed: 0 files. Kept: 0 files. (`docs/inbox/` contains only `index.md`, already empty from this session's earlier vacuum pass.)
