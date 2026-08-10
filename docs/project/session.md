---
status: Active
updated: 2026-08-10
summary: New `/shmorch reorient` command (SRE-PRR-based, tree-gated interview) + `tools/merge-chain.sh` (scripts the merge->pull->rebase PR-stack sequence). Fixed a doctrine contradiction found along the way (docs/technology/infrastructure never templated, conflicted with architecture/index.md).
---




## Latest Session — 2026-08-10 — reorient interview + deterministic merge-chain tool

**Branch:** `feature/20260810-reorient-and-merge-chain`

**What was done:**
- New `/shmorch reorient` command + `workflows/reorient.md`: a re-runnable, tree-gated
  interview (Project Focus & Shape; Production Readiness modeled on Google's SRE PRR).
  Each category and sub-question is opt-in/skippable — distinct from `orient.md`'s fixed
  one-time 6-question Context Setup, which now points to it. Wired into `SKILL.md`'s
  dispatch table and `commands/help.md`.
- Found and fixed a real bug while wiring the write target: `docs/technology/infrastructure`
  was added to `EXPECTED_DOCS` (in `self-improve.md` and `auto-update.md`) in PR #99 as a
  canonical scaffold dir, but no `templates/docs/technology/infrastructure/` ever existed —
  and it contradicts `docs/technology/architecture/index.md`'s explicit "infra is a topic
  inside architecture/, not a sibling dir" rule. Removed it from both `EXPECTED_DOCS` lists
  and `auto-update.md`'s directory check; reorient's readiness answers now write to the
  existing `docs/technology/architecture/observability.md` instead.
- New `tools/merge-chain.sh`: scripts `core/git-discipline.md`'s already-documented
  merge → pull → rebase → repeat PR-stack sequence, which kept getting skipped in practice.
  Merges each PR in order, pulls main, rebases the next branch, force-pushes on a clean
  rebase, and stops with exact resume instructions on a conflict (VERSION conflicts still
  need a judgment call, not auto-resolved). `git-discipline.md` now points to it.
- Two new tracks: `docs/project/tracks/20260810-adaptive-reorient-interview/`,
  `docs/project/tracks/20260810-deterministic-merge-chain-tool/`.
- `VERSION` bumped `1.0.7` → `1.1.0` (MINOR — new command/workflow).

**Files touched:** `commands/reorient.md` (new), `workflows/reorient.md` (new),
`workflows/orient.md`, `SKILL.md`, `commands/help.md`, `workflows/self-improve.md`,
`workflows/auto-update.md`, `tools/merge-chain.sh` (new), `core/git-discipline.md`, `VERSION`,
2 new track dirs.


**In this section:** [Pre-planning](pre-planning.md) · [timelog](timelog.md)

# Session Log

## Latest Session — 2026-08-09 — inbox fixes: auto-update scaffold gaps + prioritize reorder (PR #99, open)

**Branch:** `docs/20260808-auto-update-scaffold-gaps`

**What was done:**
- Collected two inbox items and fixed both: `auto-update.md`'s scaffold check didn't
  recognize `docs/technology/infrastructure` as canonical, and the same gap existed for
  `docs/project/prioritizer/` and `docs/project/documentarian/` — added all three to
  `workflows/auto-update.md`'s directory list and `EXPECTED_DOCS`.
- `workflows/prioritize.md`: reordered so index-creation (old Step 6) now runs before the
  present/confirm step (old Step 5) — fixes a real gap where a past `prioritize` run skipped
  creating `docs/project/prioritizer/index.md` because nothing guaranteed it existed before
  a row-update was attempted.
- Removed the two now-addressed inbox files; `docs/inbox/index.md` reverted to its prior
  committed state.
- `VERSION` bumped `1.0.3` → `1.0.4` (PATCH).
- The bulk of this session was a separate, deliberately non-shmorch effort: built a
  standalone "personal profile" pipeline at `~/.shmorch/personal-profile/` (own local-only
  git repo, not this one) that scans Claude Code session transcripts and builds an
  evidence-backed persona document. Not shmorch state — noted here only as a pointer since
  it came out of a shmorch session.

**Files touched:** `workflows/auto-update.md`, `workflows/prioritize.md`, `VERSION`,
`docs/inbox/index.md`, plus 2 deleted inbox files.

**Commits:** `ab654df` fix(workflows): close auto-update scaffold gaps + prioritize index ordering

**PR/commit:** [#99](https://github.com/ijames/shmorch/pull/99) — open, not yet merged.

**State at end of session:** on `docs/20260808-auto-update-scaffold-gaps`, PR #99 open
awaiting merge decision. `VERSION` = `1.0.4`.

**Next up — blockers:**
- Decide whether to merge PR #99.

**Next up — plans:**
- None from this session; personal-profile work continues independently outside this repo.

---

## 2026-08-04 to 2026-08-05 — catch-up (logged after the fact)

**Branch:** `main`

**What was done (catch-up — several PRs merged without a session.md update):**
- PR #95 (2026-08-04): scaffolded `docs/index.md` and `docs/technology/index.md`.
- PR #97 (2026-08-05): cross-repo skill changes now route through the inbox instead of
  direct PRs — filed alongside a never-squash merge policy and an edit-discipline gap note.
- PR #98 (2026-08-05): scoped self-improve to the local repo only, and made `$SHMORCH_HOME`
  reads branch-agnostic.

---

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

---

## 2026-08-01 to 2026-08-04 — catch-up (logged after the fact)

**Branch:** `main`

**What was done (catch-up — several PRs merged without a session.md update):**
- PR #88 (2026-08-01): README updated to match current repo state.
- PR #89 (2026-08-04): `wrap.md` now requires same-session track-Status close (was deferring to "next session," causing missed graduations); `self-improve.md` now lists open PRs by number/title/age before opening a new one, so prior self-improve PRs don't go quietly unmerged. Both patterns surfaced from the DarkBadge project's 2026-08-04 self-improve run.
- PR #90 (2026-08-04): restored `docs/project/stack.md` template scaffold — it had never actually existed in `init`'s output despite ~15 workflow files assuming it did; also fixed a malformed sibling link in `context.md` and added `stack.md`'s graduation path to `tech-stack.md`.

**State at end:** on `main`, clean tree, no active track. PR #91 (file→folder splitter design scope + block-partitioning architecture) open, raised from a DarkBadge session hitting the split gap live.

**Next up:**
- Review and merge PR #91.
- Resolve carryovers: semver-bump request (still deferred, unresolved) and the unconfirmed `TASK-PROTOCOL.md` multi-role-agent note offer.

---

## 2026-07-31 — Merge sequence for self-improve batch

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
- (continued from earlier context window) Ran `/shmorch wrap` to close the session: user corrected a design mistake — wrap Step 8.7 was writing project-specific observations into Claude Code's cross-session memory, which conflicts with shmorch's own persistence model (session.md/decisions.md/plan/ own project facts, not external CLI memory). Fixed `workflows/wrap.md` Step 8.7 to scope memory writes to genuinely cross-project developer behavioral signal only — PR #86.
- Ran self-improve (wrap Step 9) end to end: researcher agent found 3 proposals, all applied — `core/git-discipline.md` now documents that VERSION conflicts during a merge sequence are expected (always take main's value, increment `.NN`); `workflows/self-improve.md` Step 6 now gates the per-proposal branch loop on the existing 2-3 open-PR cap; `workflows/self-improve.md` Step 7 now re-sweeps PARTIAL/UNADDRESSED inbox items whose fixing PRs have since merged. Cleared 3 inbox items confirmed resolved by PRs #79/#80/#77 — PR #87.
- User manually pushed the 5 local `main` state commits to `js/main` after two `git push js main` attempts were denied by the permission system this session (direct pushes to `main` are blocked; PR merge is the only path).

**Files touched:** 72 files changed across the full merge sequence (403 insertions, 447 deletions) — spans `core/`, `workflows/`, `tools/`, `docs/project/plan/` (new directory replacing `plan.md`), `docs/inbox/` (new, replacing `NOTES.md`), `shmorch-core.md`, `VERSION`. Plus this window: `workflows/wrap.md`, `core/git-discipline.md`, `workflows/self-improve.md`, 3 `docs/inbox/` deletions.

**Commits:** 41 commits landed on `main` this session (11 feature/fix commits + their merge commits + PR #78's plan/ directory split + PR #75's inbox restructure). See `git log --oneline 66947ab..ecbd637` for the full range. Plus 5 `chore(state)` commits pushed to `main` this window.

**PR/commit status:** #67, #68, #75, #76, #77, #78, #79, #80, #81, #82, #83, #85 merged. #84 closed unmerged (superseded). #86 (wrap.md memory-scope fix) and #87 (self-improve batch) open, not yet merged.

**State at end of session:**
- On `main`, clean tree, pushed through to `js/main`. Two open PRs: #86, #87 (not merged — standard skill-change flow).
- `VERSION` — `20260731.01` on `main`; `.02` used independently on each of #86 and #87's branches (will collide on merge, resolve per the new `core/git-discipline.md` rule: take main's value + increment `.NN`).
- No semver scheme exists or was added (see `core/documentation.md`); user asked about a semver bump mid-session but deferred clarifying, so none was made — still open.
- `docs/project/plan/` directory registry (from #78) is now live, replacing the old single `plan.md`.
- `NOTES.md` is gone; `docs/inbox/` holds the items it used to track (now 6 items, down from 9).

**Next up — blockers:**
- Merge PR #86 and #87 (VERSION will collide — apply the new git-discipline.md rule).

**Next up — plans:**
- The build.md Step 3b fuller redesign (per-module model/effort selection, Workflow-orchestrated pipeline for large builds) is still deferred, scoped out of PR #82 per developer request — pick up as its own proposal if/when relevant.
- `docs/project/plan/` items from the prior batch (beads integration, cross-project knowledge base, etc.) are unchanged backlog — none were touched by this merge session.
- New plan item opened: [`watch-self-improve-and-backfill-execution.md`](plan/watch-self-improve-and-backfill-execution.md) — self-improve PRs shouldn't stack up unmerged again, and the `plan/`-directory + docs-taxonomy backfills need to be confirmed actually reaching consuming projects, not just landing on `main`.
- Revisit the "increase minor semver" request — still deferred, not resolved or withdrawn.
- Unconfirmed offer: add a clarifying note to `agents/TASK-PROTOCOL.md` about role composition happening via multiple single-role agents, not multiple inheritance within one agent — no response from user yet.

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
