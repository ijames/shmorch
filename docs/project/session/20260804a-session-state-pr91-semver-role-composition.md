↑ [../session.md](../session.md)

## 2026-08-04 — session-state resolution: PR #91 + semver migration + role-composition clarify

**Branch:** `main`

**What was done:**
- Reviewed and merged PR #91 (file→folder splitter design scope + block-partitioning architecture) — docs-only, no code.
- Resolved the carried-over semver-bump request (deferred since 2026-07-21): scoped and implemented a switch from date-based `VERSION` (`YYYYMMDD.NN`) to semantic versioning (`MAJOR.MINOR.PATCH`), now that shmorch is a public repo. Tracked in `docs/project/tracks/20260804-semver-versioning/`. Touched `VERSION`, `core/operations.md` (new MAJOR/MINOR/PATCH bump rule), `core/git-discipline.md` (conflict resolution takes main's value + the rebasing branch's own tier), `core/documentation.md` (Architecture Changelog `Date` vs `Since` split), `workflows/auto-update.md` (one-time legacy-format transition notice + dual date/semver backfill-comparison logic), `workflows/self-improve.md`. Manually verified the semver comparison function against 5 cases including the `1.0.5 < 1.0.10` numeric-not-string edge case. PR #92, merged.
- Resolved the other carryover (unconfirmed offer to clarify `TASK-PROTOCOL.md`'s "one role per agent" rule): investigated git history first — confirmed the `cross-functional-mediator` role (added `c6308c8`, 2026-06-11) never contradicted "one role per agent," since the mediator is itself a single-role agent spawned alongside others, not a multi-persona blend. Added one clarifying sentence to `TASK-PROTOCOL.md` plus a new `docs/reference/learning.md` (didn't exist yet in this repo despite being referenced by `shmorch-core.md`) with an entry on why multi-agent composition beats single-agent role-switching for independence. PR #93, merged.
- Both PRs merged one at a time with a main pull + rebase in between, per developer instruction — PR #93's VERSION conflict (still on legacy `20260804.03` when rebased onto `main` which had just moved to `1.0.0` via #92) resolved per the new git-discipline rule: took main's `1.0.0` and applied #93's own PATCH tier → `1.0.1`.

**Files touched:** `docs/project/tracks/20260804-semver-versioning/index.md` (new), `VERSION`, `core/operations.md`, `core/git-discipline.md`, `core/documentation.md`, `workflows/auto-update.md`, `workflows/self-improve.md`, `agents/TASK-PROTOCOL.md`, `docs/reference/learning.md` (new).

**PR/commit status:** #91, #92, #93 all merged.

**State at end of session:** on `main`, clean tree, `VERSION` = `1.0.1`, no open PRs, no active track.

**Next up:** nothing blocking — pick from backlog (`docs/project/plan/`).
