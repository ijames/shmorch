# Shmorch Plan

> **What belongs here:** What to build and in what order — for Shmorch itself.
> This is the live backlog for the shmorch skill, not for any project using shmorch.
> Changes here do NOT bump VERSION (docs are internal; only skill file changes affect VERSION).

---

## Current Task

None active.

---

## Backlog

### Fixes

- [ ] **Init self-guard** — `init` must detect when `TARGET` is `~/.claude/skills/shmorch/` and skip the template-copy step entirely.

- [ ] **wrap.md: BLOCKER tier** — split pick-up items into `**BLOCKER** (do first):` (max 2) and `**Next up:**`; `go.md` fast-path reads BLOCKER tier only. (`workflows/wrap.md`)

- [ ] **documentarian + prioritizer: consume outputs, don't accumulate** — findings graduate directly into target docs (`decisions.md`, `plan.md`); no growing archive of dated reports in `docs/state/`. If a finding can't be graduated immediately, it becomes a named backlog item. Affects end-of-workflow steps for both. (`workflows/documentarian.md`, `workflows/prioritize.md`, `workflows/init.md`)

- [ ] **self-improve output location enforcement** — add explicit "never write to project `docs/state/`" warning to Step 4 Task prompt. (`workflows/self-improve.md`)

- [ ] **Version monitoring across projects** — detect VERSION drift at session start; flag if `.shmorch/VERSION` ≠ skill VERSION before go.md auto-update check runs.

---

### Design & Docs

- [ ] **Curated hand-held init of shmorch skill repo** — run through the init interview on the shmorch skill repo itself to populate `docs/state/context.md`, `docs/state/session.md`, `docs/architecture/`, etc. The "shmorch shmorch" bootstrapping moment.

- [ ] **Subagent usage guide for solo dev** — document when/how Shmorch spawns subagents during solo development: parallel test-writing while fixing, research isolation, Gherkin generation. Goal: proactively spawns without being asked.
  - Candidate patterns: subagent writes tests → main thread validates; subagent researches root cause → main thread decides fix; subagent writes docs in parallel with code
  - Moved from: MoBoS plan.md 2026-05-19

- [ ] **Meta-manager role** — role distinct from documentarian; manages the shmorch skill itself: tracks what's planned, in-flight, shipped across versions. Consider: named agent role vs named responsibility in `shmorch-core.md`.

---

### Architecture

- [ ] **shmorch-core.md breakup** — god doc consuming session context; break into focused sub-documents loaded JIT by the workflow that needs them. → [track](tracks/20260601-core-breakup/index.md)

- [ ] **Core / role / workflow / command boundary cleanup** — content in wrong layers causing collision and duplication; define exclusive ownership per layer, move violators. Depends on core-breakup. → [track](tracks/20260601-boundary-cleanup/index.md)

- [ ] **Graph-first documentation** — docs as nodes, references as edges; `index.md` as surface maps; atomic single-responsibility files; context bundles for JIT loading. → [track](tracks/20260525-graph-first-docs/index.md)

- [ ] **State file discipline: tracks own their state, dev owns root state** — root-level state files must never be committed to feature branches; per-track state lives in the track directory for its full lifecycle; root files consolidated on `dev` at merge time only. → [track](tracks/20260609-state-file-discipline/index.md)

---

### Features

- [ ] **Scheduler integration** — three-tier model: in-session hygiene, cross-session rhythms, sprint boundary events. Design doc already written. Blocked on remote-agent vs CronCreate open question. → [track](tracks/20260602-scheduler-integration/index.md)

- [ ] **Cross-project knowledge base** — `knowledge/` dir in shmorch skill; concepts indexed by topic with project + commit provenance; `go.md` surfaces relevant entries at session start. → [track](tracks/20260608-cross-project-knowledge/index.md)

- [ ] **`/shmorch stage` and `/shmorch release` commands** — formalise the RC → release flow with built-in semver rules. `stage` tags `dev` as `vX.Y.Z-rc.N` (version bump from Conventional Commits since last tag); `release` merges RC to `main`, tags final version, confirms deploy pipeline fired. Surfaced from MoBoS first release 2026-06-09.

- [ ] **`docs/state/plans/` directory for planning artifacts** — Planning artifacts (pre-build interview outputs, design sketches, Agent-generated plans) are ending up in `~/.claude` instead of the project's `docs/state/`. Introduce `docs/state/plans/` with `index.md`, parallel to `prioritizer/` and `documentarian/`. Any planning artifact produced in a session goes here as `YYYYMMDD_<slug>.md`. `init.md` scaffolds the directory. `~/.claude` reserved for shmorch self-improve artifacts only. Flagged DarkBadge 2026-05-25.

- [ ] **Umbrella meta-project: portfolio and project aggregator** — Shmorch managing a meta-project above all individual projects: registry of all active Shmorch-managed projects, their status, live URLs, skills/technologies, career-positioning signal, feed for a portfolio site. `/shmorch init` creates a `meta/` project type with `meta/projects.md` (registry) and `meta/positioning.md` (income paths, target clients, pitch language). The meta-project is itself Shmorch-managed. Flagged from DarkBadge/SHMING 2026-05-26.

---

### Deferred

- [ ] **Beads integration investigation** — evaluate replacing markdown task files with [Beads](https://github.com/gastownhall/beads) (Dolt-backed dependency graph). Trial on one active project before committing.
  - Condition: after a project using Shmorch heavily enough to feel the pain of flat markdown task files, or when Beads has more documented usage examples.
  - Moved from: MoBoS plan.md 2026-05-19

---

## Completed

<!-- Items closed here when the skill change is merged to main. -->
