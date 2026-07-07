# Shmorch (Pronouced "Shmork" as in "Shming" + "Orchestra")

Shmorch is an autonomous development orchestrator that runs on any agent CLI — omp (Oh My Pi), Pi, Codex, Gemini, opencode, Cursor, Antigravity, and Claude Code. It wraps a project with persistent state, structured workflows, specialist agent roles, and session continuity — so you can pick up exactly where you left off, switch CLIs freely, and the agent behaves like an active development lead rather than a stateless assistant.

**Version:** 20260707.02

---

## What Problem It Solves

Agent CLIs start fresh every conversation. Shmorch fixes that by maintaining state files the model reads at session start: what the project is, what's in flight, what was decided, and what happened last time. It also installs safety hooks that block destructive commands, and defines structured workflows so the model follows a consistent process from idea through shipping. It loads through whichever context file your CLI reads — `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` — all pointing at one source of truth (`.shmorch/AGENTS.md`).

---

## How It Works

Shmorch installs a `.shmorch/` directory inside your project. That directory contains:

- **State files** — plain markdown files the agent reads and writes to track context, plans, decisions, and session history
- **Workflow files** — step-by-step instructions for each phase of development (intake, analyze, spec, design, build, vacuum)
- **Agent role files** — personas the agent adopts when spawning specialist subagents
- **Tool scripts** — bash utilities for timekeeping, checkpointing, and cleanup
- **Safety hooks** — block `rm -rf`, force-push, and other destructive commands (a Claude shell hook + an omp `tool_call` hook; other CLIs rely on their own approval mode plus the model-enforced safety rules)

At the start of a session the agent asks one question — `go`, `resume`, or `nothing` — describing what's already loaded (Shmorch identity + project rules via the `AGENTS.md`/`CLAUDE.md`/`GEMINI.md` import chain) and what each option does, so you stay in control of when the full bootstrap or state read happens. On Claude Code this fires on the real session-start event; on other CLIs it runs on the first turn. After a `/clear`-style reset, type `/shmorch go` or `/shmorch resume` (or `shmorch go` as plain text) directly.

---

## Commands

### `/shmorch init [path]`

Initializes a new Shmorch workspace. If a path is given, installs there; otherwise uses the current directory.

- Detects whether a codebase already exists (by looking for `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.)
- Copies all templates into `.shmorch/`
- Writes `CLAUDE.md` with a project-specific override section
- Writes `shmorch.sh`, a launcher that sets env vars and opens Claude
- If existing code is detected: immediately runs `/shmorch discover` without waiting for the user

### `/shmorch discover`

Deep audit of an existing codebase. Fills in `docs/state/context.md` and `docs/state/stack.md` from what's actually in the project — not from guesses.

1. Runs a structural sweep in parallel: top-level layout, dependency files, runtime constraints, entry points, README, test setup
2. Spawns analyst agents (up to 4 in parallel) — one per major code directory — each writing an analysis file to `docs/state/`
3. Synthesizes findings into `context.md` and `stack.md`
4. Reports blockers and cruft found, then hands off to the `go` flow

### `/shmorch go [topic]`

Starts a working session. Claude reads state, orients, and asks what to do.

1. Stamps `SESSION_START` in the timelog
2. Checks if the skill version is newer than the project version; prompts to update if so
3. Reads `context.md` and `stack.md` — runs a Context Setup interview if unfilled
4. Reads `session.md` — summarizes what happened last time
5. Reads `plan.md` — shows active tracks and current focus
6. Checks `git status` — flags uncommitted changes
7. Asks: "What do you want to work on?"

### `/shmorch resume`

Fast re-entry into a session that's already underway — skips everything `go` does except the essentials.

1. Reads `session.md` and `plan.md` only — no version check, no context/stack interview, no git status, no gap or memory scanning
2. Leads with the BLOCKER / "Pick up immediately" note if one exists, otherwise the current task
3. Points to `/shmorch go` if the full check is actually needed

### `/shmorch wrap`

Closes the session — stamps end time, summarizes what happened, updates all state files.

1. Reads session, plan, timelog, and decisions files
2. Runs `git log` to identify commits since the last session entry
3. Asks one question: "What was the focus of this session? Any decisions worth recording?"
4. Stamps `SESSION_END`, writes a new entry to `session.md`, demotes the previous one
5. Updates `plan.md` if any track statuses changed
6. Appends to `decisions.md` if any architectural decisions were made
7. Shows elapsed session time via `$SHMORCH_HOME/tools/duration.sh today`

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

1. Runs `vacuum.sh` to generate a timestamped report in `docs/state/`
2. Summarizes findings: count and location of annotations, empty test files
3. Walks through findings one at a time: "Delete, keep, or address now?"
4. Acts on decisions — deletes with confirmation, logs new tracks in `plan.md`, or fixes inline
5. Stamps `VACUUM` in the timelog

### `/shmorch checkpoint`

Quick-save: commits only `docs/state/` files to git. Use mid-session to preserve planning state without running a full commit.

### `/shmorch update`

Updates the project's Shmorch templates to match the installed skill version. Run when `go` reports a newer version is available.

### `/shmorch help`

Shows all available commands.

---

## Workflow Phases

During a session, Claude follows structured phase workflows read from `.shmorch/workflows/`. The orchestrator reads the relevant file before starting each phase.

| Phase | When |
|---|---|
| **Intake** | New conversation or unclear goal — establish what the user wants |
| **Analyze** | Existing code to examine before making changes |
| **Spec** | Define what to build — written spec before any design |
| **Design** | Architecture decisions before writing code |
| **Build** | Implementation |
| **Vacuum** | After build, or any time cruft is noticed |

The model's identity while in Shmorch mode: active development lead, one question at a time, plans before code, specs before plans, ruthless about waste.

---

## Agent Roles

Shmorch can spawn specialist subagents for parallelizable or role-specific work. Role files live in `.shmorch/agents/roles/`.

| Role | Purpose |
|---|---|
| **Orchestrator** | Lead agent — decomposes work, assigns subagents, integrates outputs |
| **Analyst** | Reads and audits code; never modifies files |
| **Architect** | Makes structure and API decisions |
| **Specwriter** | Writes formal specs from user intent |
| **Implementer** | Writes code from spec and design |
| **Documentarian** | Writes and updates docs |
| **Vacuumer** | Scans for cruft, dead code, stale TODOs |

Agents are spawned when work is parallelizable, needs a different role, or would block the main conversation. Skipped for single-file edits, simple questions, or tasks under ~2 minutes.

---

## Persistent State Files

All state lives in `docs/state/` as plain markdown.

| File | Purpose |
|---|---|
| `context.md` | Project identity, tech stack, preferences, never-do rules |
| `plan.md` | Current task (with status), backlog, completed work |
| `spec.md` | Active specification |
| `decisions.md` | Architecture decision log |
| `session.md` | Cross-session summary — what happened each time |
| `stack.md` | Runtime, dependencies, external constraints, upgrade opportunities |
| `timelog.md` | Event timestamps for every session and task |

---

## Timekeeping

Every significant transition is stamped to `docs/state/timelog.md` via `timelog.sh`.

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

Run `bash $SHMORCH_HOME/tools/duration.sh today` to see elapsed session time. Run `$SHMORCH_HOME/tools/duration.sh last` to see time since the last event.

---

## Safety

Shmorch installs Claude Code hooks in `.shmorch/.claude/hooks/`:

- **pre-tool hook** — blocks `rm -rf`, `git push --force`, and other destructive commands before they run
- **stop hook** — fires at session end (used for cleanup or reminders)

`.shmorch/.claude/settings.json` pre-allows common read-only commands so Claude doesn't prompt for permission on routine operations.

Additional rules enforced by the model:
- Never delete without user confirmation
- Never push to git without user confirmation
- Never switch branches without asking
- Always write `plan.md` before multi-file changes
- One question at a time — never a barrage

---

## Project Structure

```
.shmorch/           (installed inside your project)
├── AGENTS.md          — project rules + overrides; imports shmorch-core.md (the source of truth)
├── CLAUDE.md          — one-line @AGENTS.md shim (Claude Code import chain)
├── home               — absolute skill path ($SHMORCH_HOME) for this machine
├── VERSION            — tracks which skill version was used to init/update
├── state/
│   ├── context.md
│   ├── plan.md
│   ├── spec.md
│   ├── decisions.md
│   ├── session.md
│   ├── stack.md
│   └── timelog.md
├── workflows/
│   ├── intake.md
│   ├── analyze.md
│   ├── spec.md
│   ├── design.md
│   ├── build.md
│   └── vacuum.md
├── agents/
│   ├── orchestrator.md
│   └── roles/
│       ├── analyst.md
│       ├── architect.md
│       ├── specwriter.md
│       ├── implementer.md
│       ├── documentarian.md
│       └── vacuumer.md
├── tools/
│   ├── timelog.sh
│   ├── duration.sh
│   ├── checkpoint.sh
│   └── vacuum.sh
├── .claude/           — Claude adapter: settings.json + hooks (pre-tool, session-start, stop)
└── .omp/              — omp adapter: hooks/pre/safety.ts

AGENTS.md / CLAUDE.md / GEMINI.md   (project root — thin pointers into .shmorch/, one per CLI convention)
shmorch.sh                          (project root — launcher that selects your CLI)
```

---

## Skill Structure (this repo)

This repository is the Shmorch skill — the source installed into `$SHMORCH_HOME/` (e.g. `~/.claude/skills/shmorch/`) and copied into projects on `init`.

```
SKILL.md           — skill metadata and command dispatch table
VERSION            — skill version (format: YYYYMMDD.NN)
commands/          — one file per command (/shmorch go, init, wrap, etc.)
templates/         — everything copied into a project on /shmorch init
NOTES.md           — development notes and known gaps
```

---

## Typical Session Flow

```
bash shmorch.sh              # open Claude in the project
                             # Claude asks: go, resume, or nothing?

/shmorch go                  # full bootstrap, if you didn't already answer "go" above

... work happens ...

/shmorch vacuum              # catch TODOs and dead code
/shmorch commit              # group and commit changes
/shmorch wrap                # close session, update state
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
