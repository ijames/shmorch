---
status: Active
updated: 2026-07-21
summary: Two concurrent processes on this repo — see Current Task. Messaging-provider track opened; wrap-friction fixes + bounded context reads already shipped (PR #58, #57).
---

# Shmorch Plan

> **What belongs here:** What to build and in what order — for Shmorch itself.
> This is the live backlog for the shmorch skill, not for any project using shmorch.
> Changes here do NOT bump VERSION (docs are internal; only skill file changes affect VERSION).

---

## Current Task

**Two independent processes are active on this repo concurrently as of 2026-07-21 — keep them separate, do not merge into one track or one commit:**

1. **Messaging provider design** (this session) — → [track](tracks/20260721-messaging-provider/index.md). Interactive design work, not yet built.
2. **Self-improve** (separate automated process — see prior commit `cc2997a` "upgrade(shmorch): wrap-friction fixes from self-improve") — periodically proposes and PRs its own findings directly; not scoped by or dependent on the messaging-provider track. If its output lands mid-session, log it under its own commit/PR, not folded into messaging-provider work.

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

- [ ] **Messaging provider — optional, per-project, not hardcoded to one Zulip workspace** — separate thin provider skills (Zulip, Slack, etc.), opt-in per project via `AGENTS.md` pointer (mirrors Docs Placement Hook), keys live in MCP config/`.env` never in Shmorch, scoped to post+read (not a fully generic integration abstraction). Surfaced 2026-07-21. → [track](tracks/20260721-messaging-provider/index.md)

- [ ] **State store shape** — evaluate a graph/wiki backend for state (tracks/decisions) so `go` pulls the current-focus subgraph, not whole files; includes the Beads candidate and a richer structured-front-matter candidate. Split from entrypoint-consolidation's Phase 3. → [track](tracks/20260717-state-store-shape/index.md)

- [ ] **shmorch-core.md breakup** — god doc consuming session context; break into focused sub-documents loaded JIT by the workflow that needs them. → [track](tracks/20260601-core-breakup/index.md)

- [ ] **Core / role / workflow / command boundary cleanup** — content in wrong layers causing collision and duplication; define exclusive ownership per layer, move violators. Depends on core-breakup. → [track](tracks/20260601-boundary-cleanup/index.md)

- [ ] **Graph-first documentation** — docs as nodes, references as edges; `index.md` as surface maps; atomic single-responsibility files; context bundles for JIT loading. → [track](tracks/20260525-graph-first-docs/index.md)

- [ ] **State file discipline: tracks own their state, dev owns root state** — root-level state files must never be committed to feature branches; per-track state lives in the track directory for its full lifecycle; root files consolidated on `dev` at merge time only. → [track](tracks/20260609-state-file-discipline/index.md)

- [ ] **Shared state branch: git-decoupled state layer** — state files conflict on every branch merge because git's divergence model and shared mutable state are structurally incompatible. Candidate: orphan `state` branch + permanent git worktree at `.shmorch-state/`; state lives outside the branch graph entirely. Supersedes state-file-discipline if adopted. → [track](tracks/20260614-shared-state-branch/index.md)

---

### Features

- [ ] **Structural focus enforcement — no nagging, mechanical** — Shmorch can't enforce focus if nothing invokes it. Two options: (1) `init` writes a CLAUDE.md rule: "Before any task, state today's single objective; flag divergence before proceeding." (2) A `SessionStart` hook that auto-cats `.shmorch/sprint-calendar.md` + current state into context — makes drift-checking zero-effort instead of discipline-dependent. Option 2 is stronger (hook fires automatically, no reliance on the developer remembering to invoke a command). Surfaced 2026-06-11.

- [ ] **Cross-functional UX: participant awareness** — Shmorch should know who the participants are in the work (developer, reviewer, stakeholder) and surface relevant context per role. `go.md` could prompt for active participants and adjust what it shows at session start (e.g. reviewer-facing summary vs builder-facing task list). "U" in UX = the people doing the work, not just the end-user. Surfaced 2026-06-11.

- [ ] **Scheduler integration** — three-tier model: in-session hygiene, cross-session rhythms, sprint boundary events. Design doc already written. Blocked on remote-agent vs CronCreate open question. → [track](tracks/20260602-scheduler-integration/index.md)

- [ ] **Cross-project knowledge base** — `knowledge/` dir in shmorch skill; concepts indexed by topic with project + commit provenance; `go.md` surfaces relevant entries at session start. → [track](tracks/20260608-cross-project-knowledge/index.md)

- [ ] **`/shmorch stage` and `/shmorch release` commands** — formalise the RC → release flow with built-in semver rules. `stage` tags `dev` as `vX.Y.Z-rc.N` (version bump from Conventional Commits since last tag); `release` merges RC to `main`, tags final version, confirms deploy pipeline fired. Surfaced from MoBoS first release 2026-06-09.

- [ ] **`init` should explain what it creates** — When init writes `.shmorch/.claude/settings.json`, hooks, and scaffold files, it gives no explanation. Users pause and ask why. Fix: add a "What got created" summary block to init Step 7 (the report), one line per file with its purpose. Proactive explanation, not reactive. Flagged NOTES.md 2026-04-01.

- [ ] **`build.md` richer Definition of Done** — Current DoD is condensed and loses important guards: (1) "fill in ↑ source and → destination links before writing anything else — if you can't fill in the destination, the track isn't scoped"; (2) Tests section should ask "did any new public methods get added or changed?" not just a flat bullet; (3) stronger no-partial-commit language: "if tests or docs are missing, do not commit the code alone"; (4) add a four-item pre-commit checklist summary block as an at-a-glance gate. Flagged NOTES.md 2026-04-27.

- [ ] **`/shmorch verify` parity check command** — Docs↔tests↔code parity check: README audit (exists, project-specific, run commands accurate), structure gaps (expected files per component), scenario→step definition coverage (GREEN/RED/MISSING), docs→scenario coverage (undocumented claims), setup.md command accuracy. Writes `docs/state/parity-report-YYYY-MM-DD.md`. Current stack-specific prototype in `js/hack:workflows/verify.md` — generalize for any stack. Gaps surface as plan.md items; never silently pass.

- [ ] **Deliberate Esc-Esc snapshot boundaries in workflows** — Claude Code's Esc-Esc rolls back to any prior conversation checkpoint non-destructively. Shmorch should design workflow boundaries to be clean Esc-Esc targets: flush all state to files first, emit a clean one-liner summary, then launch any heavy subagent work. Pattern: `[write session.md + timelog] → [clean pause line] → [spawn subagent]`. This makes rollback cheap — only steering messages are lost, not inline analysis. Applies especially to `go` (before auto-update), `build` (before each phase), `documentarian`. Subagent model enhances this: main thread checkpoints stay clean and meaningful.

- [ ] **`docs/state/plans/` directory for planning artifacts** — Planning artifacts (pre-build interview outputs, design sketches, Agent-generated plans) are ending up in `~/.claude` instead of the project's `docs/state/`. Introduce `docs/state/plans/` with `index.md`, parallel to `prioritizer/` and `documentarian/`. Any planning artifact produced in a session goes here as `YYYYMMDD_<slug>.md`. `init.md` scaffolds the directory. `~/.claude` reserved for shmorch self-improve artifacts only. Flagged DarkBadge 2026-05-25.

- [ ] **Umbrella meta-project: portfolio and project aggregator** — Shmorch managing a meta-project above all individual projects: registry of all active Shmorch-managed projects, their status, live URLs, skills/technologies, career-positioning signal, feed for a portfolio site. `/shmorch init` creates a `meta/` project type with `meta/projects.md` (registry) and `meta/positioning.md` (income paths, target clients, pitch language). The meta-project is itself Shmorch-managed. Flagged from DarkBadge/SHMING 2026-05-26.

---

### Deferred

- [ ] **Generic external-integration provider abstraction** — broaden the messaging-provider pattern (post/read, opt-in, `AGENTS.md` pointer, no secrets in Shmorch) beyond messaging to any external service (deploy notifications, issue trackers, etc.).
  - Condition: only after a second non-messaging need actually appears — premature until then.
  - Related: `docs/state/tracks/20260721-messaging-provider/`

- [ ] **Beads integration investigation** — evaluate replacing markdown task files with [Beads](https://github.com/gastownhall/beads) (Dolt-backed dependency graph). Trial on one active project before committing.
  - Condition: after a project using Shmorch heavily enough to feel the pain of flat markdown task files, or when Beads has more documented usage examples.
  - Moved from: MoBoS plan.md 2026-05-19
  - Related: `docs/state/tracks/20260717-state-store-shape/` (the `navigate`↔beads mapping lives there — moved from `entrypoint-consolidation` Phase 3 on 2026-07-17, originally from `navigate.md` 2026-07-07)

---

## Completed

<!-- Items closed here when the skill change is merged to main. -->

- [x] **Wrap-friction fixes (self-improve)** — `go.md` escalates when 3+ sessions in a row end without a real wrap; `build.md` syncs track `index.md` Status before opening the PR; `self-improve.md` cross-checks `decisions.md`/`AGENTS.md` before re-proposing an already-resolved pattern; `vacuum.md` gained an untracked-file scan escalating to a backlog item after 2+ passes. PR #58 merged 2026-07-18.

- [x] **Bounded timelog/session reads** — `orient.md`, `wrap.md`, `self-improve.md` no longer `Read` `session.md`/`timelog.md` whole; bounded to current/most-recent entries via `tail`/`awk`. PR #57 merged 2026-07-18.

- [x] **Merge policy: regular merge, not squash** — disabled squash and rebase merge on the GitHub repo (`gh repo edit --enable-squash-merge=false --enable-rebase-merge=false`), leaving only merge commits allowed. Enforced at the platform level — no doc or runtime check needed. 2026-06-19.

- [x] **Multi-CLI portability (omp / Pi / Codex / Gemini / opencode / Cursor / Antigravity)** — P0 + P1 + P2 all done: AGENTS.md-first context chain with per-CLI root files (AGENTS/CLAUDE/GEMINI) + plain-text bootstrap for literal-`@` CLIs; `$SHMORCH_HOME` indirection (recipe in `core/portability.md`, resolved at session start, stamped into `.shmorch/home`, 117 path refs codemod'd); CLI-neutral subagent protocol, dispatch, launchers, and omp TS safety hook; `/shmorch sync` migrates existing repos; README stale Claude-only spots fixed; scheduler doc scoped as Claude-only. `docs/state/tracks/20260707-multi-cli-portability/index.md`. Closed 2026-07-17.

- [x] **Entry-point consolidation** — `go` as the single dispatcher (provision → orient); Phase 2 context trim (`core/operations.md` carve-out, front-matter previews on `docs/state/*.md`, `docs/state/index.md` skeleton index, `orient.md` Step 0 pulse check). Phase 3 (store shape) split to `tracks/20260717-state-store-shape/`. `docs/state/tracks/20260707-entrypoint-consolidation/index.md`. Closed 2026-07-17.

- [x] **Docs solidification: continuous placement + version-triggered backfill** — `vacuumer` role gained a "docs placement" hunt category backed by an optional `PostToolUse` hook (`templates/.claude/hooks/post-tool-docs.sh`) that fires right after each docs write/edit; opt-in via `.shmorch/AGENTS.md`. `core/documentation.md` gained an Architecture Changelog (`Compat: additive | backfill`); `auto-update.md` Step 2.8 offers scoped, per-entry, opt-in backfill using the existing `VERSION` date as the comparison axis — no new semver. Standalone `solidify` command dropped after feedback split the problem into these two concerns. `docs/state/tracks/20260717-docs-solidification-framework/index.md`. PR #55 merged 2026-07-17.
