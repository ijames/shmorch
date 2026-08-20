### Self-Improve Proposals — 2026-07-22 | Project: treeclusion

#### Proposal 1: Preflight branch check before doc/build work starts
**Pattern:** The pre-commit hook that blocks direct-to-main commits (per AGENTS.md "Branching Discipline") is discovered *mid-commit* rather than anticipated before work starts — the developer does the work on `main`, then gets blocked at commit time and has to branch reactively.
**Frequency:** 2/2 sessions to date (the only two sessions with substantive work):
- 2026-07-21: "Committed the scaffold on a feature branch (pre-commit hook blocks direct-to-main commits)" — scaffold init.
- 2026-07-22: "Discovered mid-commit that non-state docs require a branch (pre-commit hook blocked a direct-to-main commit of `docs/product/*.md`) — branched to `docs/20260722-stretchtext-spec` for that commit and the track/plan update commit."
**File:** `workflows/build.md` (or wherever the pre-build interview / task-start sequence lives — apply the same preflight to `workflows/spec.md` and `workflows/documentarian.md` since both sessions involved doc writing, not code)
**Change:** Add an explicit preflight step, before any file write that isn't under `docs/state/`: check current branch; if on `main` (or the integration branch) and the target path is a non-state doc or code, create/switch to the appropriate `feat|fix|docs/YYYYMMDD-<slug>` branch *first*, per the existing Branching Discipline rule — don't wait for the hook to reject the commit.
**Improvement:** Removes the "oh, blocked, let me branch now" interruption from the commit step; branch creation becomes part of task setup instead of a recovery action, and commits land on the right branch the first time.

### Already addressed
None found — `decisions.md` is still an empty template (only the placeholder entry exists), so no prior decision entries to check against. AGENTS.md documents the branching *policy* itself but not a proactive-check step, so Proposal 1 is not a duplicate of existing doctrine — it operationalizes a rule that's currently enforced reactively by a git hook rather than proactively by the workflow.

### No-action observations
- `docs/to_review/` and `docs/development/code-styleguides/` are flagged by the scaffold-reverse-check as not in the canonical `EXPECTED_DOCS` list and not present in `.shmorch/project_docs_log.md` (which doesn't exist yet). Both dirs were created at the 2026-07-21 scaffold-init commit, i.e. a single occurrence, not a recurring pattern — and the Docs Placement Hook is enabled per AGENTS.md, so this may just mean the hook hasn't fired yet or the log file is created lazily on first flagged write. Worth re-checking next run once `project_docs_log.md` exists or these dirs get more activity.
- No fat project-workflow-file copies found (`.shmorch/workflows/` contains only `README.md`, no project-level workflow overrides yet — nothing to check against the `# Extends:` convention).
- Only one BLOCKER-flagged item in `session.md` next-up notes (backlink open questions / rendering-stack choice), and it hasn't recurred across a second session yet — too early to call it a stalling pattern.
