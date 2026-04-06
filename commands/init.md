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

## Step 2 — Detect existing code and stack

Look in `TARGET` for stack indicator files (do NOT look inside `shmorch/`):
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

## Step 5 — Write top-level launcher

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

## Step 6 — Branch on project type

### If IS_FRESH_PROJECT:

Initialize minimal state files (use template defaults — all placeholders).

Report to user:
```
✓ Shmorch initialized in TARGET/shmorch/

Launch: bash TARGET/shmorch.sh
  or just: claude (from TARGET)

Shmorch will ask setup questions on your first session.
```

Stop here. The go flow will handle context setup.

### If HAS_EXISTING_CODE:

Initialize minimal state files — write `state/session.md` with:
```
## Latest Session
Initialized on existing project via /shmorch init on DATE.
Discovery pending — run /shmorch discover to analyze codebase.
```

Leave `state/context.md` and `state/stack.md` as template placeholders.

Report to user:
```
✓ Shmorch initialized in TARGET/shmorch/
  Existing codebase detected — running discovery now...
```

Then immediately execute the `discover` command (read `commands/discover.md` and run it). Do not stop and wait for the user.
