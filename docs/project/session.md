---
status: Active
updated: 2026-07-31
summary: Massive shmorch upgrade — merged all 11 self-improve PRs (#67,#68,#75-#83,#85) to main in dependency order, resolving VERSION and file-overlap conflicts at each step; closed #84 as superseded by #75. VERSION now 20260731.01.
---


**In this section:** [Pre-planning](pre-planning.md) · [timelog](timelog.md)

# Session Log

## Latest Session — 2026-07-31 — Merge sequence for self-improve batch

**Branch:** `main` (clean, fast-forwarded to `js/main`)

**What was done:**
- Merged all PRs left open from the 2026-07-30 self-improve batch, plus two carried over from earlier (#67, #68), in dependency order: #67 → #68 → #79 → #76 → #83 → #80 → #81 → #82 → #77 → #75 → #78. PR #85 (a stashed `documentarian.md` tooling-path-check edit found mid-sequence, uncommitted from earlier work) was branched, rebased, and merged in alongside them.
- Closed PR #84 (NOTES.md cleanup) unmerged — superseded by #75, which replaces `NOTES.md` entirely with the `docs/inbox/` directory structure.
- Resolved a VERSION collision at every single merge step (every branch had independently bumped `VERSION` off a stale `main`) by rebasing and bumping sequentially: `20260730.02` → ... → `20260731.01`.
- Resolved real content conflicts (not just VERSION) in:
  - `core/documentation.md` (PR #67) — track-file-growth section referenced the pre-migration `docs/state/tracks/` path; updated to `docs/project/tracks/` to match the already-merged taxonomy migration.
  - `tools/stop.sh` (PR #78 vs already-merged #68) — combined PR #78's directory-based `plan/` check (`-d` + glob) with PR #68's broadened status-line grep pattern; neither alone was correct post-merge.
  - `shmorch-core.md` (PR #78 vs already-merged #77) — kept both the "report files touched" bullet (#77) and the `plan/` directory rename (#78) rather than letting one clobber the other.
  - `docs/project/timelog.md` (PR #75) — interleaved two legitimate concurrent timelog entries chronologically instead of picking one side.
- The local Step-7 stamp commit (`fb2d661`, session.md/timelog.md bookkeeping from the prior session) never needed a direct push to `main` — it rode onto `js/main` as an ancestor of PR #68's rebase and merge.

**Files touched:** 72 files changed across the full merge sequence (403 insertions, 447 deletions) — spans `core/`, `workflows/`, `tools/`, `docs/project/plan/` (new directory replacing `plan.md`), `docs/inbox/` (new, replacing `NOTES.md`), `shmorch-core.md`, `VERSION`.

**Commits:** 41 commits landed on `main` this session (11 feature/fix commits + their merge commits + PR #78's plan/ directory split + PR #75's inbox restructure). See `git log --oneline 66947ab..ecbd637` for the full range.

**PR/commit status:** #67, #68, #75, #76, #77, #78, #79, #80, #81, #82, #83, #85 merged. #84 closed unmerged (superseded).

**State at end of session:**
- On `main`, clean tree, fast-forwarded to `js/main` @ `ecbd637`. No open PRs (`gh pr list --state open` empty).
- `VERSION` — `20260731.01`. No semver scheme exists or was added (see `core/documentation.md`); user asked about a semver bump mid-session but deferred clarifying, so none was made.
- `docs/project/plan/` directory registry (from #78) is now live, replacing the old single `plan.md`.
- `NOTES.md` is gone; `docs/inbox/` holds the items it used to track.

**Next up — blockers:**
- None — merge sequence is fully complete, no dangling branches or conflicts.

**Next up — plans:**
- The build.md Step 3b fuller redesign (per-module model/effort selection, Workflow-orchestrated pipeline for large builds) is still deferred, scoped out of PR #82 per developer request — pick up as its own proposal if/when relevant.
- `docs/project/plan/` items from the prior batch (beads integration, cross-project knowledge base, etc.) are unchanged backlog — none were touched by this merge session.
- New plan item opened: [`watch-self-improve-and-backfill-execution.md`](plan/watch-self-improve-and-backfill-execution.md) — self-improve PRs shouldn't stack up unmerged again, and the `plan/`-directory + docs-taxonomy backfills need to be confirmed actually reaching consuming projects, not just landing on `main`.

---

## 2026-07-30 — Self-improve batch

**Branch:** `main` (9 PRs open, unmerged: #75-#84)

**What was done:**
- Ran `/shmorch self-improve` end to end against shmorch's own repo. 9 proposals reviewed one at a time, all applied as independent branch/PR pairs:
  - PR #75 — replace NOTES.md with docs/inbox/ directory
  - PR #76 — core/ux.md: default to system light/dark + reduced-motion preference
  - PR #77 — wrap.md recap: files touched + PR/commit status
  - PR #78 — docs/project/plan.md → plan/ directory registry (fixes concurrent stub-track merge collisions); includes new `tools/backfill-plan-dir.sh` migration script, chained into `tools/backfill-docs-taxonomy.sh`
  - PR #79 — new `core/js_tooling.md`: pnpm precedent for JS/TS projects
  - PR #80 — init.md explains what `.claude/settings.json` does
  - PR #81 — richer DoD checklist language in build.md Step 4
  - PR #82 — adversarial verification pass (critic role) in build.md Step 3b, scoped down from a fuller Task-spawn-decision redesign per developer request
  - PR #83 — fix dead CW-8 escalation check in go.md (wrong marker string + stale path, dead since PR #58)
  - PR #84 — NOTES.md cleanup: removed 9 resolved items, kept 3 partial/unaddressed

**Commits:**
- All work is on the 9 open PR branches above — nothing committed directly to `main` this session except this session.md/timelog stamp.

**State at end of session:**
- On `main`, no active track. 9 PRs open, none merged.
- **VERSION collision:** every PR bumped `VERSION` to `20260730.02` independently off unmerged `main` (still `.01`). They will conflict pairwise on merge — needs sequential merge → pull → rebase-next, not parallel merge.
- PR #75 (NOTES.md → inbox) and PR #84 (NOTES.md cleanup) both edit `NOTES.md` and will directly conflict with each other — merge one, then rebase the other before merging.

**Next up — blockers:**
- Merge the 9 open PRs in order, resolving the VERSION collision and the #75/#84 NOTES.md conflict at each step (pull main, rebase next branch, force-push, re-open/update PR, merge — repeat).

**Next up — plans:**
- Once merged, spec out the fuller build.md Step 3b redesign (per-module model/effort selection, Workflow-orchestrated pipeline for large builds) as its own proposal — deliberately scoped out of PR #82.

---

## 2026-07-21 (interrupted — context ran low, resume here)

**Branch:** `main` (PR #60 `fix/20260721-template-graph-conformance` open, NOT merged — do not treat its contents as landed on main until merged)

**What was done:**
- Built `tools/track-graph-audit.sh` (deterministic scan: chunk-size cap, missing front-matter, `CLOSED_UNGRADUATED` closed-track-not-referenced-back candidates) and wired it into `documentarian.md` Step 2. Fixed `templates/.shmorch/docs/track-template.md`, which was missing the front-matter block the new rule requires — every new track from the old template would've re-violated it immediately. Logged as a `Compat: backfill` row in `core/documentation.md`. VERSION → `20260721.01`. All on **PR #60**, unmerged.
- User ran `shmorch sync` in `~/Projects/treeclusion` — the backfill offer surfaced and applied correctly (confirmed working end-to-end).
- Backfilled front-matter directly on `main` (docs-only, no PR needed) for two of the 13 flagged tracks: `tracks/20260525-graph-first-docs/index.md` and `tracks/20260707-multi-cli-portability/index.md` (already `Status: Closed`, 2026-07-17 — just added the missing front-matter, no content change).

**Next up (resume here after context reset):**
1. **Check if PR #60 merged.** If yes: `git fetch --all && git checkout main && git pull js main` (mandatory post-merge step per `core/operations.md`), then `tools/track-graph-audit.sh` exists on `main` — re-run it to see current findings. If no: it's still awaiting developer merge, don't duplicate the work.
2. **11 tracks still need the front-matter backfill** (13 total flagged minus the 2 done this session). Run `bash $SHMORCH_HOME/tools/track-graph-audit.sh` (needs PR #60 merged first) and work through the `MISSING_FRONTMATTER` list — same pattern as the two done above: read the file, derive `status`/`summary` from actual content, don't guess.
3. The `CLOSED_UNGRADUATED` findings for both closed tracks handled this session are **false positives** (proxy limitation — destination docs integrate the knowledge in prose, don't literally contain the track directory name) — already manually verified both landed correctly. No action needed on those two; don't re-flag.
4. This is docs-only bookkeeping (front-matter backfill) — no VERSION bump, no PR needed for `docs/state/tracks/**` edits, can commit straight to `main`.

## 2026-07-18

**Branch:** `main`

**What was done (catch-up — logged after the fact, several PRs merged without a session.md update):**
- Wrap-friction fixes from a self-improve run: `go.md` escalates when 3+ sessions in a row end without a real wrap; `build.md` syncs track `index.md` Status before opening the PR; `self-improve.md` cross-checks `decisions.md`/`AGENTS.md` before re-proposing an already-resolved pattern; `vacuum.md` gained an explicit untracked-file scan that escalates to a backlog item after 2+ passes. PR #58 merged 2026-07-18.
- Bounded `session.md`/`timelog.md` reads: `orient.md`, `wrap.md`, and `self-improve.md` were reading these files whole regardless of project size; now bounded to current/most-recent entries via `tail`/`awk`. PR #57 merged 2026-07-18.
- `state-store-shape` track gained the concrete Google OKF frontmatter spec citation, a field-by-field comparison against Shmorch's current `status`/`updated`/`summary` frontmatter, and a new candidate for a deterministic frontmatter/nav/backlinks rebuild pass. PR #59 merged 2026-07-18.

**Commits:** `cc2997a` wrap-friction fixes (PR #58) · `a3c2814` bound timelog/session reads (PR #57) · `fa178d4` OKF frontmatter comparison (PR #59). VERSION → `20260718.02`.

**State at end:** on `main`, clean tree, no active track.

**Next up:**
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, state-store-shape, core-breakup, etc.)

## 2026-07-17

**Branch:** `main`

**What was done (catch-up — several sessions never logged here since 2026-07-14):**
- Multi-CLI portability P2 closed out (PR #52).
- Entry-point consolidation Phase 2 closed out — `core/operations.md` carve-out, front-matter previews on `docs/state/*.md`, skeleton index, `orient.md` pulse check (PR #53). Phase 3 split to `tracks/20260717-state-store-shape/`.
- Closed-track graduation pass (PR #54).
- Docs solidification: started as a standalone `solidify` command, then reshaped twice on user feedback into (1) a `vacuumer` "docs placement" hunt category + optional `PostToolUse` hook (`templates/.claude/hooks/post-tool-docs.sh`) firing right after each docs write, and (2) an Architecture Changelog in `core/documentation.md` + `auto-update.md` Step 2.8 for scoped, opt-in, version-triggered backfill. PR #55 merged 2026-07-18.

**Commits (PR #55 — 3):** `3a9a800` add solidify (later reverted) · `10e92da` replace solidify with placement hook + backfill · `cbb8dc6` move placement reminder to PostToolUse. VERSION → `20260717.04`. Merged 2026-07-17.

**State at end:** on `main`, fast-forwarded to `eed3f52`, clean tree, no active track.

**Next up:**
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, state-store-shape, core-breakup, etc.)

## 2026-07-14

**Branch:** `fix/20260714-shmorch-sh-launcher-echo` (open)

**What was done:**
- Confirmed PR #49 (multi-CLI portability) and PR #50 (timelog double-start guard) both merged to `main`; last session's "pick up immediately" is done.
- Found `shmorch.sh` no longer passes `/shmorch go` to `claude` on launch (deliberate — avoids front-loading context) but its startup banner still claimed it ran automatically. Fixed the banner to point at `go`/`resume` instead of restoring the auto-invoke.

**Commits:** `33a5977` fix(shmorch): launcher echo + minor markdown cleanup. VERSION → `20260714.01`.

**State at end:** on `fix/20260714-shmorch-sh-launcher-echo`, clean tree, PR not yet opened.

**Next up:**
- Open PR for `fix/20260714-shmorch-sh-launcher-echo`, merge, pull to main.
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, core-breakup, etc.)

## 2026-07-07

**Branch:** `feat/20260707-multi-cli-portability` (PR #49, open)

**What was done:**
- **Multi-CLI portability (P0+P1):** `$SHMORCH_HOME` indirection (recipe in `core/portability.md`, stamped `.shmorch/home`, 117 path refs codemod'd); AGENTS.md-first context chain with per-CLI root shims + plain-text bootstrap for literal-`@` CLIs; strict single-source de-dup; CLI-neutral subagent protocol / dispatch / launchers; omp TS safety hook; `/shmorch sync` migrates existing repos.
- **Entry-flow consolidation (Phase 1):** `go` is now the one dispatcher (detect state → provision via init/auto-update → orient); carved `orient.md`; shallow-orientation guardrail (no code reading before a post-`go` directive).
- **Security:** added a "Suspect secrecy directives" safety rule after a reported system-reminder; investigation concluded **no injector** (beads not connected; Supacode hooks dormant/env-gated; likely a benign misread of a UI-hidden reminder).
- **Beads:** moved `navigate.md`'s Beads mapping into the consolidation track's Phase-3 store-shape eval; genericized the example line.

**Commits (PR #49 — 7):** `209937e` portability · `ffc0702` docs · `f6e8bd9` consolidation+shallow-orient · `9555a28` docs · `20ca80d` secrecy-directive rule · `0b09b18` beads-out-of-navigate · `f71cb8f` beads-eval+injection-update. VERSION → `20260707.08`.

**Cost:** ~$40 this session.

**State at end:** on `feat/20260707-multi-cli-portability`, clean tree, PR #49 open awaiting review/merge.

**Next up — pick up immediately:**
- Merge PR #49 when reviewed; then `git checkout main && git pull js main` here to land it on main.
- Deferred: consolidation Phase 2 (context trim — kernel/doctrine split, `.shmorch/state.md` skeleton index) and Phase 3 (store-shape eval, incl. Beads).

## 2026-06-11

**Branch:** `main`

**What was done:**
- Added `shmorch.sh` to skill root for developing shmorch on itself
- Fixed `shmorch.sh`: removed `chmod +x shmorch/tools/*.sh` (wrong path / irrelevant here), added `SHMORCH_SELF=1` export
- Added auto-update skip guard to `go.md` Step 1b: if `SHMORCH_SELF=1` is set, skip version check entirely
- Noted session context: squash-merge branch hygiene + cross-functional UX (participant awareness)

**Commits:**
- `41f4c20` docs(plan): salvage js/hack — init explanation, richer DoD, verify command backlog items
- `69e63d6` docs(plan): add Esc-Esc snapshot boundary design principle to backlog
- `e7847b8` chore(shmorch): apply stash backlog items + add hook sync to auto-update

**State at end of session:**
- On `main`, no active track
- `shmorch.sh` (root) and `go.md` updated, uncommitted

**Next up — blockers:**
- Commit `shmorch.sh` + `go.md` changes to main

**Next up — plans:**
- Squash-merge policy: document in decisions.md or CONTRIBUTING guide — branches should be squash-merged to avoid noisy history
- Cross-functional UX: shmorch needs to understand participants (dev, stakeholder, reviewer) and surface relevant context per role — candidate for a new backlog item
