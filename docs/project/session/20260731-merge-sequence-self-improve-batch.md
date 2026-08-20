↑ [../session.md](../session.md)

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
- New plan item opened: [`watch-self-improve-and-backfill-execution.md`](../plan/watch-self-improve-and-backfill-execution.md) — self-improve PRs shouldn't stack up unmerged again, and the `plan/`-directory + docs-taxonomy backfills need to be confirmed actually reaching consuming projects, not just landing on `main`.
- Revisit the "increase minor semver" request — still deferred, not resolved or withdrawn.
- Unconfirmed offer: add a clarifying note to `agents/TASK-PROTOCOL.md` about role composition happening via multiple single-role agents, not multiple inheritance within one agent — no response from user yet.
