# Shmorch (Pronouced "Shmork" as in "Shming" + "Orchestra")

Shmorch is an autonomous development orchestrator that runs on any agent CLI — omp (Oh My Pi), Pi, Codex, Gemini, opencode, Cursor, Antigravity, and Claude Code. It wraps a project with persistent state, structured workflows, specialist agent roles, and session continuity — so you can pick up exactly where you left off, switch CLIs freely, and the agent behaves like an active development lead rather than a stateless assistant.

See `VERSION` for the current skill version (format: `YYYYMMDD.NN`).

---

## What Problem It Solves

Agent CLIs start fresh every conversation. Shmorch fixes that by maintaining state files the model reads at session start: what the project is, what's in flight, what was decided, and what happened last time. It also installs safety hooks that block destructive commands, and defines structured workflows so the model follows a consistent process from idea through shipping. It loads through whichever context file your CLI reads — `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` — all pointing at one source of truth (`.shmorch/AGENTS.md`).

---

## How It Works

Shmorch installs a `.shmorch/` directory inside your project, plus a `docs/` tree at the project root. `.shmorch/` contains:

- **Workflow files** — step-by-step instructions for each phase of development (intake, analyze, spec, design, build, vacuum, documentarian, and more)
- **Agent role files** — personas the agent adopts when spawning specialist subagents
- **Tool scripts** — bash utilities for timekeeping, checkpointing, and cleanup
- **Safety hooks** — block `rm -rf`, force-push, and other destructive commands (a Claude Code hook set + an omp `tool_call` hook; other CLIs rely on their own approval mode plus the model-enforced safety rules)

Project state itself — plans, decisions, session history, architecture — lives in plain markdown under `docs/` at the project root (see [Persistent State](#persistent-state)), not inside `.shmorch/`.

At the start of a session the agent asks one question — `go`, `resume`, or `nothing` — describing what's already loaded (Shmorch identity + project rules via the `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` import chain) and what each option does, so you stay in control of when the full bootstrap or state read happens. On Claude Code this fires on the real session-start event; on other CLIs it runs on the first turn. After a `/clear`-style reset, type `/shmorch go` or `/shmorch resume` (or `shmorch go` as plain text) directly.

---

## Commands

### `/shmorch init [path]`

Initializes a new Shmorch workspace. If a path is given, installs there; otherwise uses the current directory.

- Detects whether a codebase already exists (by looking for `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.)
- Copies all templates into `.shmorch/` and scaffolds the `docs/` skeleton (`docs/project/`, `docs/product/`, `docs/technology/`, `docs/reference/`, `docs/inbox/`)
- Writes `.shmorch/AGENTS.md` (the source of truth, with a project-specific override section) plus thin root shims — `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` — so whichever context file your CLI reads resolves to it
- Writes `shmorch.sh`, a launcher that picks and opens your CLI (Claude Code, omp, etc.)
- If existing code is detected: immediately runs `/shmorch discover` without waiting for the user

### `/shmorch discover`

Deep audit of an existing codebase. Fills in `docs/project/context.md` and the technology docs from what's actually in the project — not from guesses.

1. Runs a structural sweep in parallel: top-level layout, dependency files, runtime constraints, entry points, README, test setup
2. Spawns analyst agents (up to 4 in parallel) — one per major code directory — each writing an analysis file to `docs/project/`
3. Synthesizes findings into `context.md` and the technology docs
4. Reports blockers and cruft found, then hands off to the `go` flow

### `/shmorch go [topic]`

Starts a working session. Claude reads state, orients, and asks what to do.

1. Stamps `SESSION_START` in the timelog
2. Checks if the skill version is newer than the project version; prompts `/shmorch auto-update` if so
3. Reads `context.md` — runs a Context Setup interview if unfilled
4. Reads `session.md` — summarizes what happened last time
5. Reads `plan/` — shows active tracks and current focus
6. Checks `git status` — flags uncommitted changes
7. Asks: "What do you want to work on?"

### `/shmorch resume`

Fast re-entry into a session that's already underway — skips everything `go` does except the essentials.

1. Reads `session.md` and `plan/` only — no version check, no context interview, no git status, no gap or memory scanning
2. Cross-checks git/PRs before trusting `session.md` — flags if state looks stale
3. Leads with the BLOCKER / "Pick up immediately" note if one exists, otherwise the current task
4. Points to `/shmorch go` if the full check is actually needed

### `/shmorch wrap`

Closes the session — stamps end time, summarizes what happened, updates all state files, and runs self-improve automatically at the end.

1. Reads session, plan, timelog, and decisions files
2. Runs `git log` to identify commits since the last session entry
3. Asks one question: "What was the focus of this session? Any decisions worth recording?"
4. Stamps `SESSION_END`, writes a new entry to `session.md`, demotes the previous one
5. Updates `plan/` if any track statuses changed; offers to graduate closed tracks whose knowledge hasn't landed in docs yet
6. Appends to the relevant `decisions/` file if any architectural decisions were made
7. Shows elapsed session time, patches doc sibling navigation, and commits all state-file changes in one `chore(state)` commit
8. If on a non-main branch: offers to push + open a PR before returning to `main`
9. Asks the standing developer prompts (unlogged decisions, unplanned scope, next-session risk) and integrates answers into the right state file
10. Runs `/shmorch self-improve` automatically to close out the session

### `/shmorch commit`

Groups all changes into logical, independent units and commits each one.

1. Runs `git status`, `git diff`, `git diff --cached`, and `git log` in parallel
2. Groups changes by logical independence: feature units (code + tests + docs), shmorch state, config/infra
3. Checks each code-containing group for missing tests and docs — defers or writes them before committing
4. Presents a numbered plan of commits with files listed; waits for user confirmation
5. Commits each group individually using `git add <specific files>` — never `git add -A`
6. Shows the final log

Safety rules: never commits secrets, never force-pushes, never skips hooks, never amends published commits.

### `/shmorch vacuum`

Scans the project for waste — TODOs, FIXMEs, HACKs, empty test files — then triages with the user one finding at a time.

1. Runs `vacuum.sh` to generate a timestamped report in `docs/project/`
2. Summarizes findings: count and location of annotations, empty test files
3. Walks through findings one at a time: "Delete, keep, or address now?"
4. Acts on decisions — deletes with confirmation, logs new tracks in `plan/`, or fixes inline
5. Stamps `VACUUM` in the timelog

### `/shmorch documentarian`

Audits and repairs the gap between code/tests and documentation. Verifies that closed tracks delivered their knowledge to the right `docs/` sections, finds undocumented features, and surfaces stale content. Run after one or more tracks close.

### `/shmorch prioritize`

Re-ranks the backlog and surfaces effort/value tradeoffs. Updates `docs/project/plan/` only after developer confirmation. Run before starting a new sprint.

### `/shmorch sprinter`

Manages the active sprint — reads and updates `docs/project/schedule/sprint.md`, checks sprint health and risk flags.

### `/shmorch self-improve`

Retrospective self-improvement. Reads session history and the timelog to surface friction patterns (min. 2 occurrences to count), then proposes targeted changes to shmorch's own workflows and commands. Runs automatically at the end of every `/shmorch wrap`; can also be run manually. Developer reviews and confirms every proposed change before anything is written — approved changes go out as a branch + PR against the skill repo, never a direct commit to `main`.

### `/shmorch research`

Proactive external research — finds advances in AI-assisted development and LLM orchestration practices, then proposes specific improvements to shmorch. Developer reviews every proposed change before anything is written.

### `/shmorch status`

Prints a concise project health snapshot — sprint progress, task state, backlog depth, recent commits, and test counts where available. For a quick "where are we?" without reading full state files.

### `/shmorch checkpoint`

Quick-save: commits only `docs/project/` files to git. Use mid-session to preserve planning state without running a full commit.

### `/shmorch auto-update` (aliases: `sync`, `update`)

Brings this project's Shmorch installation up to date with the current skill version (skill → project direction). Runs automatically when `go` detects a version mismatch; can also be run manually anytime. Offers any backfill migrations (e.g. doc-taxonomy restructures) needed to bring an older project layout current.

### `/shmorch help`

Shows all available commands.

---

## Workflow Phases

During a session, Claude follows structured phase workflows read from `$SHMORCH_HOME/workflows/` (or a project override in `.shmorch/workflows/`). The orchestrator reads the relevant file before starting each phase.

| Phase | When |
|---|---|
| **Intake** | New conversation or unclear goal — establish what the user wants |
| **Analyze** | Existing code to examine before making changes |
| **Spec** | Define what to build — written spec before any design |
| **Design** | Architecture decisions before writing code |
| **Build** | Implementation — tests before code, adversarial review before done |
| **Vacuum** | After build, or any time cruft is noticed |
| **Documentarian** | After a track closes — verify its knowledge landed in `docs/` |

The model's identity while in Shmorch mode: active development lead, one question at a time, plans before code, specs before plans, ruthless about waste.

---

## Agent Roles

Shmorch can spawn specialist subagents for parallelizable or role-specific work. Role files live in `agents/roles/` (skill) or `.shmorch/agents/roles/` (project override). Every task is scoped to exactly one role per agent — a task that needs multiple perspectives spawns multiple single-role agents, not one agent wearing several hats.

| Role | Purpose |
|---|---|
| **Orchestrator** | Lead agent — decomposes work, assigns subagents, integrates outputs |
| **Analyst** | Reads and audits code; never modifies files |
| **Architect** | Makes structure and API decisions |
| **Specwriter** | Writes formal specs from user intent |
| **Implementer** | Writes code from spec and design |
| **Documentarian** | Writes and updates docs |
| **Vacuumer** | Scans for cruft, dead code, stale TODOs |
| **Researcher** | Introspective (session/timelog retrospective) or external (web) research |
| **Critic** | Adversarial review pass — tries to break a design or implementation before it ships |
| **Prioritizer** | Ranks backlog items by effort/value |
| **Sprinter** | Tracks sprint health and progress |
| **Cross-functional mediator** | Reconciles conflicting concerns across roles/disciplines on one piece of work |

Agents are spawned when work is parallelizable, needs a different role, or would block the main conversation. Skipped for single-file edits, simple questions, or tasks under ~2 minutes.

---

## Persistent State

All state lives in `docs/` at the project root as plain markdown — never in `.shmorch/` and never in the CLI's own cross-session memory (project facts belong in the repo, version-controlled with the code; only genuinely cross-project developer-behavior signal belongs in CLI memory).

**`docs/project/`** — in-flight and ephemeral, replaces the old single-file `state/`:

| File / dir | Purpose |
|---|---|
| `context.md` | Project identity, tech stack summary, preferences, never-do rules |
| `plan/` | Current task (with status), backlog, completed work — a directory registry, not a single file |
| `spec.md` | Active specification |
| `session.md` | Cross-session summary — what happened each time |
| `timelog.md` | Event timestamps for every session and task |
| `tracks/` | Design/dev/impl track directories — knowledge distributes into `docs/<category>/` on close |
| `schedule/` | Sprint tracking |
| `process/` | Paved-road divergences and project-specific overrides |

**`docs/product/`** and **`docs/technology/`** — the permanent, authoritative record:

| Category | Covers |
|---|---|
| `product/decisions/`, `technology/decisions/` | The only two decision loci — permanent, current-state-only (history lives in git, not the doc) |
| `technology/architecture/` | Permanent architectural record |
| `product/strategy/`, `product/design/`, `product/features/` | What the system does and why |
| `technology/development/` | How it's built — stack, code style, testing |

**`docs/reference/`** — lookup-only material (research findings, install/quickstart instructions). **`docs/inbox/`** — pre-ingestion holding pen for observations awaiting `/shmorch self-improve` triage.

**Graduation rule:** `docs/project/` should never accumulate completed work — when a spec ships or a decision stabilizes, its knowledge moves into the permanent `docs/` tree and the project-level file is cleared back to a stub.

---

## Timekeeping

Every significant transition is stamped to `docs/project/timelog.md` via `timelog.sh`.

| Event | When |
|---|---|
| `SESSION_START` | Session opens |
| `SESSION_END` | Session closes |
| `TASK_START` | Work begins on a task |
| `TASK_DONE` | Task completes |
| `PHASE` | Workflow phase changes (e.g. "intake → spec") |
| `AGENT_SPAWN` | Subagent launched |
| `AGENT_DONE` | Subagent completed |
| `VACUUM` | Vacuum scan ran |
| `DECISION` | Architectural decision recorded |

`timelog.md` is append-only and grows without bound — workflows read only a bounded tail (`tail -N`), never the whole file. Run `bash $SHMORCH_HOME/tools/duration.sh today` to see elapsed session time. Run `$SHMORCH_HOME/tools/duration.sh last` to see time since the last event.

---

## Safety

Shmorch installs a safety hook per CLI adapter:

- **Claude Code** (`.claude/hooks/` at the project root, wired via `.claude/settings.json`) — a `PreToolUse` hook blocks `rm -rf`, `git push --force`, and direct pushes to `main`/`master` before they run; a `SessionStart` hook and a `Stop` hook (from `$SHMORCH_HOME/tools/stop.sh`, reminding about in-progress tracks) fire at the relevant points. `settings.json` also pre-allows common read-only commands so Claude doesn't prompt for permission on routine operations.
- **omp** (`.omp/hooks/pre/safety.ts`) — a `tool_call` hook enforcing the same destructive-command blocklist.
- **A git pre-commit hook** (`.githooks/pre-commit`) blocks accidental commits of code changes directly to `main`/`dev` — state-only commits are exempt.
- **Other CLIs** rely on their own approval mode plus the model-enforced safety rules below.

Additional rules enforced by the model:
- Never delete without user confirmation
- Never push to git without user confirmation
- Never switch branches without asking
- Always write `plan/` before multi-file changes
- One question at a time — never a barrage

---

## Project Structure

```
.shmorch/            (installed inside your project)
├── AGENTS.md           — project rules + overrides; imports shmorch-core.md (the source of truth)
├── CLAUDE.md           — one-line @AGENTS.md shim (Claude Code import chain)
├── VERSION             — tracks which skill version was used to init/update
├── agents/
│   ├── TASK-PROTOCOL.md
│   └── roles/           — project-local role overrides, if any
├── workflows/            — project-local workflow overrides, if any
├── tools/                — project-local tool overrides, if any
└── docs/
    ├── track-template.md
    └── setup-github.md

docs/                 (project root — the real state lives here, not in .shmorch/)
├── project/            — in-flight: context.md, plan/, spec.md, session.md, timelog.md, tracks/, schedule/, process/
├── product/             — decisions/, strategy/, design/, features/
├── technology/          — decisions/, architecture/, development/
├── reference/            — research/, instructions/
└── inbox/                — captured observations awaiting self-improve triage

.claude/              — Claude Code adapter: settings.json + hooks (session-start, pre-tool, post-tool, stop)
.omp/                 — omp adapter: hooks/pre/safety.ts
.githooks/            — git pre-commit branch-protection hook
AGENTS.md / CLAUDE.md / GEMINI.md   (project root — thin pointers into .shmorch/, one per CLI convention)
shmorch.sh                          (project root — launcher that selects your CLI)
```

---

## Skill Structure (this repo)

This repository is the Shmorch skill — the source installed into `$SHMORCH_HOME/` (e.g. `~/.claude/skills/shmorch/`) and copied into projects on `init`.

```
SKILL.md           — skill metadata and command dispatch table
shmorch-core.md    — doctrine entry point loaded every session
VERSION            — skill version (format: YYYYMMDD.NN)
commands/          — one file per command (/shmorch go, init, wrap, self-improve, etc.)
workflows/         — step-by-step procedures each command dispatches to
agents/roles/      — specialist agent persona files
core/              — doctrine files (git discipline, documentation taxonomy, TDD, UX, operations, ...)
tools/             — shell scripts for timekeeping, state commits, doc-nav patching, backfills, etc.
templates/         — everything copied into a project on /shmorch init
docs/inbox/        — captured observations awaiting self-improve triage
```

Skill-level changes (anything under `commands/`, `workflows/`, `agents/`, `core/`, `tools/`, or `shmorch-core.md`) always go out as a branch + PR, bumping `VERSION`, never a direct commit to `main`. See `core/git-discipline.md` and `core/operations.md`.

---

## Typical Session Flow

```
bash shmorch.sh              # open Claude in the project
                             # Claude asks: go, resume, or nothing?

/shmorch go                  # full bootstrap, if you didn't already answer "go" above

... work happens ...

/shmorch vacuum              # catch TODOs and dead code
/shmorch commit               # group and commit changes
/shmorch wrap                 # close session, update state, run self-improve
```

For a new project:

```
/shmorch init ~/path/to/project
bash ~/path/to/project/shmorch.sh
/shmorch go
```

For an existing codebase:

```
/shmorch init ~/path/to/project   # auto-runs discover
/shmorch go                        # orient and start working
```
