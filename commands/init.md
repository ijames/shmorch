# Command: init

Initialize a Shmorch workspace at the given path (or current directory if no argument).

**Target:** the remainder of `$ARGUMENTS` after "init" — an absolute or `~`-prefixed path. If empty, use the current working directory.

Follow these steps exactly:

## Step 1 — Resolve target directory

- If an argument follows "init", expand `~` to the home directory and use that as `TARGET`
- Otherwise, `TARGET` is the current working directory
- `PROJECT_NAME` = the basename of `TARGET`
- `SHMORCH_DIR` = `TARGET/shmorch`

If `SHMORCH_DIR` already exists and contains a `CLAUDE.md`, tell the user it's already initialized and stop.

## Step 2 — Detect existing code

Look in `TARGET` for any of these indicator files/patterns (do NOT look inside `shmorch/`):
- `package.json` → Node.js/JavaScript
- `Cargo.toml` → Rust
- `pyproject.toml` or `requirements.txt` or `setup.py` → Python
- `go.mod` → Go
- `pom.xml` or `build.gradle` → Java/Kotlin
- `*.sln` or `*.csproj` → C#/.NET
- `Gemfile` → Ruby
- `composer.json` → PHP

Also:
- Read `TARGET/README.md` (first 40 lines) if it exists, to extract a project description hint
- List top-level directories in `TARGET`, excluding: hidden dirs, `node_modules`, `target`, `dist`, `build`, `.git`, `shmorch`

Record:
- `HAS_EXISTING_CODE` = true if any indicator found or non-empty code dirs exist
- `DETECTED_STACK` = list of detected languages/frameworks
- `DESCRIPTION_HINT` = first sentence from README if available, else empty
- `CODE_DIRS` = list of top-level code directories (relative to TARGET)

## Step 3 — Create shmorch/ directory structure

Copy all files from `${CLAUDE_SKILL_DIR}/templates/` into `SHMORCH_DIR/`, preserving directory structure. Make all `.sh` files executable (chmod +x).

## Step 4 — Write CLAUDE.md

Write `SHMORCH_DIR/CLAUDE.md`:

```
@shmorch-core.md

---

## Project Overrides — PROJECT_NAME

### What This Project Does
DESCRIPTION_HINT_OR_PLACEHOLDER

### Tech Stack
DETECTED_STACK_OR_PLACEHOLDER

### Never Do Without Asking
<!-- -->
```

## Step 5 — Pre-fill state/context.md (existing projects only)

If `HAS_EXISTING_CODE` is true, overwrite `SHMORCH_DIR/state/context.md`:

```markdown
# Project Context
> Filled in on first Shmorch session, or edit directly.

## Project Name
PROJECT_NAME

## What It Does
DESCRIPTION_HINT_OR_TODO

## Tech Stack
DETECTED_STACK_OR_TODO

## Existing Codebase?
Yes. Key directories: CODE_DIRS_RELATIVE_TO_SHMORCH

## Preferences
- Code style: <!-- fill in -->
- Test framework: <!-- fill in -->
- Commit style: <!-- fill in -->

## Never Do Without Asking
<!-- fill in -->
```

Also overwrite `SHMORCH_DIR/state/session.md`:

```markdown
# Session Log

## Latest Session
Initialized on existing project via /shmorch init on DATE.
Code at: CODE_DIRS_RELATIVE_TO_SHMORCH
Context pre-filled from project analysis — verify state/context.md before starting.

---

## History
```

## Step 6 — Write top-level launcher

Write `TARGET/shmorch.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
chmod +x shmorch/tools/*.sh shmorch/.claude/hooks/*.sh 2>/dev/null || true
echo ""
echo "Starting Shmorch — PROJECT_NAME"
echo "  /shmorch go    — start session"
echo "  /shmorch help  — all commands"
echo "  Esc+Esc or /rewind anytime to restore a previous state"
echo ""
claude
```

Make it executable.

## Step 7 — Report to user

```
✓ Shmorch initialized in TARGET/shmorch/
✓ context.md pre-filled from project analysis    ← only if HAS_EXISTING_CODE

Launch: bash TARGET/shmorch.sh
  or just: claude (from TARGET)

[If existing project:]
Review shmorch/state/context.md — it was auto-filled from your project.
Add any preferences and "never do" rules before your first session.

[If new project:]
Shmorch will ask setup questions on your first session.
```
