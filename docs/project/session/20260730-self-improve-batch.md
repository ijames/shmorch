↑ [../session.md](../session.md)

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
