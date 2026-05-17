# Workflow: init

Initialize a Shmorch workspace at the given path (or current directory if no argument).

## When to use
- Setting up Shmorch in a new project
- Adding Shmorch to an existing codebase
- Re-running after a failed or partial init

## Inputs
- `TARGET` — absolute or `~`-prefixed path (from `$ARGUMENTS`), or current working directory if empty

## Roles
- None — runs inline (may trigger `discover` workflow for existing codebases)

---

## Step 1 — Resolve target directory

- If an argument follows "init", expand `~` to the home directory and use that as `TARGET`
- Otherwise, `TARGET` is the current working directory
- `PROJECT_NAME` = the basename of `TARGET`
- `SHMORCH_DIR` = `TARGET/.shmorch`

If `SHMORCH_DIR` already exists and contains a `CLAUDE.md`, tell the user Shmorch is already initialized and stop.

---

## Step 2 — Detect existing code and stack

Look in `TARGET` for stack indicator files (do NOT look inside `.shmorch/`):
- `package.json` → Node.js/JavaScript
- `Cargo.toml` → Rust
- `pyproject.toml` or `requirements.txt` or `setup.py` → Python
- `go.mod` → Go
- `pom.xml` or `build.gradle` → Java/Kotlin
- `*.sln` or `*.csproj` → C#/.NET
- `Gemfile` → Ruby
- `composer.json` → PHP

Also check: does TARGET contain any non-hidden, non-empty directories (excluding: `node_modules`, `target`, `dist`, `build`, `.git`, `shmorch`, `env*`, `venv*`)?

Record:
- `HAS_EXISTING_CODE` = true if any stack indicator found OR non-empty code dirs exist
- `IS_FRESH_PROJECT` = true only if TARGET is empty or contains only hidden files / config stubs

---

## Step 3 — Merge templates into project (never overwrite existing files)

The skill's `templates/` directory (located alongside `SKILL.md` and `commands/` in the shmorch skill folder) mirrors the project root. Each subdirectory maps directly to the same path under `TARGET`. Copy files with this rule: **skip any file that already exists at the destination.** Never overwrite.

Specifically:

**`templates/.shmorch/` → `TARGET/.shmorch/`**
Copy selectively — agents, workflows, and shmorch-core.md are NOT copied:
- `VERSION`, `tools/`, `docs/` — copy in full
- `shmorch-core.md` — **do NOT copy**. It lives only at `~/.claude/skills/shmorch/shmorch-core.md` and is referenced via absolute `@` path from `.shmorch/CLAUDE.md`.
- `.shmorch/agents/` — copy `README.md` and `roles/README.md` only (stubs). Default agents live in the skill at `~/.claude/skills/shmorch/agents/` and are never copied into projects.
- `.shmorch/workflows/` — copy `README.md` only (stub). Default workflows live in the skill at `~/.claude/skills/shmorch/workflows/` and are never copied into projects.

Make all `.sh` files executable (chmod +x).

This gives the project empty override directories ready to receive project-specific files, while the skill remains the canonical source for all defaults.

**`templates/.claude/` → `TARGET/.claude/`**
Copy hooks and settings. Skip if files already exist — never overwrite an existing hook.

**`templates/docs/` → `TARGET/docs/`**
Merge carefully:
- `docs/state/` files: copy only if the destination file does not exist. Never overwrite an existing `plan.md`, `context.md`, `decisions.md`, etc.
- `docs/product/`, `docs/development/`, `docs/architecture/`, `docs/reference/`, `docs/guides/`: create the directory and copy `.gitkeep` only if the directory doesn't exist at all.
- `docs/state/schedule/`: copy `README.md` only if the directory doesn't exist at all.
- `docs/tracks/README.md`: copy only if no `docs/tracks/` exists yet.

**`templates/shmorch.sh` → `TARGET/shmorch.sh`**
Copy only if `TARGET/shmorch.sh` does not exist. Make executable.

After copying, tell the user what was created vs. skipped.

---

## Step 4 — Write .shmorch/CLAUDE.md

Write `SHMORCH_DIR/CLAUDE.md` (only if it doesn't exist — covered by Step 3 skip rule, but write explicitly here):

```
@~/.claude/skills/shmorch/shmorch-core.md

---

## Project Overrides — PROJECT_NAME

### What This Project Does
<!-- fill in -->

### Tech Stack
DETECTED_STACK_OR_PLACEHOLDER

### Permission Matrix

**Run without asking:**
- Read files, list files, run tests, run linter on single file, run tsc --noEmit on single file
- Tag files or code blocks for vacuum/deletion (note the tag, but do not delete)

**Always ask first:**
- Package installs (npm/pip/etc.), git push, actually deleting files, running full build
- Adding new dependencies, changing package.json / requirements / lock files

Where possible, encode prohibitions as lint rules with remediation instructions — markdown instructions alone are probabilistic.

### Never Do Without Asking
<!-- fill in -->
```

---

## Step 5 — Wire root CLAUDE.md

Check `TARGET/CLAUDE.md`:

**If it does not exist:** Create it:
```
@.shmorch/CLAUDE.md

# PROJECT_NAME

<!-- Add project-level context here that applies across all sessions. -->
```

**If it exists:** Check whether it already contains `@.shmorch/CLAUDE.md`. If not, prepend that line (and a blank line after it) to the top of the existing file. Do not touch any other content.

Explain to the user what was done (created vs. amended).

---

## Step 6 — Branch on project type

### If IS_FRESH_PROJECT:

State files are already in place from Step 3 (template placeholders). Nothing further to initialize.

Report to user:
```
Shmorch initialized in .shmorch/

What got created:
  .shmorch/              — Shmorch workspace (core, tools, agents, workflows)
  docs/state/           — State files (context, plan, decisions, session, stack)
  docs/product/ etc.    — SDLC doc scaffold (empty, ready to fill)
  docs/state/schedule/  — Closed sprint archive
  .claude/hooks/        — Safety hooks (blocks rm -rf, git push --force)
  shmorch.sh            — Launcher script
  CLAUDE.md             — [created or amended to import .shmorch/CLAUDE.md]

Launch: bash shmorch.sh
  or just: claude (from TARGET)

Shmorch will ask setup questions on your first /shmorch go session.
```

Stop here. The go flow handles context setup.

### If HAS_EXISTING_CODE:

Write `docs/state/session.md` (overwrite template default only):
```
## Latest Session
Initialized on existing project via /shmorch init on DATE.
Discovery pending — run /shmorch discover to analyze codebase.
```

Report to user:
```
Shmorch initialized in .shmorch/
  Existing codebase detected — running discovery now...
```

Then immediately execute the `discover` workflow (read `workflows/discover.md` and run it). Do not stop and wait for the user.
