# Shmorch Plan

> **What belongs here:** What to build and in what order — for Shmorch itself.
> This is the live backlog for the shmorch skill, not for any project using shmorch.
> Changes here do NOT bump VERSION (docs are internal; only skill file changes affect VERSION).

---

## Current Task

None active.

---

## Backlog

### Active (prioritized)

- [ ] **Init self-guard** — `init` workflow must detect when `TARGET` is `~/.claude/skills/shmorch/` and skip the template-copy step entirely. Shmorch's own `docs/` are live project docs, not template stubs. Clobbering them with blank templates would be destructive.

- [ ] **Curated hand-held init of shmorch skill repo** — Run through the init interview process on the shmorch skill repo itself to properly populate `docs/state/context.md`, `docs/state/session.md`, `docs/architecture/`, etc. The backlog exists; the rest of the shmorch docs skeleton does not. This is the "shmorch shmorch" bootstrapping moment.

- [ ] **Subagent usage guide for solo dev** — Document when and how Shmorch should spawn subagents during solo development: parallel test-writing while fixing, research isolation, Gherkin generation. Goal: Shmorch should proactively spawn for parallelizable work (e.g. write Gherkin while main thread fixes the bug) without being asked.
  - Candidate patterns: subagent writes tests → main thread validates; subagent researches root cause → main thread decides fix; subagent writes docs in parallel with code
  - Phase: Design (pattern doc in `.shmorch/workflows/` or a guide in `docs/`)
  - Moved from: MoBoS plan.md 2026-05-19

- [ ] **Meta-manager role** — A role distinct from the documentarian. The documentarian writes project docs from code and closed tracks. The meta-manager manages the shmorch skill itself: tracks what's planned, what's in-flight, what's been shipped across versions. Analogous to a product owner for the tool. This role would own `docs/state/` in the shmorch skill repo. Consider whether this is a named agent role or just a named responsibility in `shmorch-core.md`.

- [ ] **Beads integration investigation** — Evaluate replacing Shmorch markdown task files with [Beads](https://github.com/gastownhall/beads) (Dolt-backed dependency graph). Trial on one active track before committing.
  - Phase: Design · Analyze
  - Condition to re-evaluate: After a project using Shmorch heavily enough to feel the pain of flat markdown task files — or when Beads has more documented usage examples.
  - Moved from: MoBoS plan.md 2026-05-19

- [ ] **wrap.md: BLOCKER tier in pick-up items** — From self-improve-20260501 Proposal 3 (unapplied). At wrap, split "pick up immediately" items into two explicit tiers: `**BLOCKER** (do first):` (max 2 items) and `**Next up:**` (everything else). go.md fast-path on re-entry reads the BLOCKER tier only. Prevents lower-priority carry-forward items from obscuring actual blockers across sessions. File: `workflows/wrap.md`.

- [ ] **documentarian + prioritizer run artifacts: subfolders + date naming** — From DarkBadge 2026-05-25. Documentarian parity reports go to `docs/state/documentarian/YYYYMMDD_parity-report.md`; prioritizer proposals go to `docs/state/prioritizer/YYYYMMDD_priority-proposal.md`. Each subfolder has an `index.md` listing runs chronologically. Prevents single-run artifacts from floating in `docs/state/` root alongside permanent files. init.md should scaffold these directories with index stubs. Files: `workflows/documentarian.md`, `workflows/prioritize.md`, `workflows/init.md`, `templates/docs/state/documentarian/index.md`, `templates/docs/state/prioritizer/index.md`.

- [ ] **self-improve output location enforcement** — Early project sessions wrote self-improve output to project `docs/state/` instead of `~/.claude/`. The workflow already specifies `~/.claude/self-improve-YYYYMMDD-<slug>.md` as the correct path, but the agent wrote to the project. Add an explicit "never write to project docs/state/" warning to self-improve Step 4 (Task prompt) so the researcher agent can't place files in the wrong location. File: `workflows/self-improve.md`.

- [ ] **Graph-first documentation: surface-map indexes and size discipline** — Design concept from DarkBadge 2026-05-25. Docs are nodes; references are edges. `index.md` files are surface maps (which features appear where, for which consumers), not flat listings. Feature files are single-responsibility, small (~200–400 lines max), and are referenced (transcluded) — never copied. Consumer-aware traversal means different readers follow different subgraphs. Shmorch should: (1) enforce single-responsibility via documentarian size-limit checks; (2) scaffold `index.md` as a surface map, not a flat listing; (3) document a "context bundle" concept — named traversal paths for common task types. Connects to JIT context loading (Anthropic guide). See also: DarkBadge `docs/development/notes.md` §Graph-First Documentation Architecture.

---

## Completed

<!-- Items closed here when the skill change is merged to main. -->
