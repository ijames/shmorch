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

## Step 0 — Self-init guard

Before anything else, resolve what the target directory will be (applying the same argument-expansion logic as Step 1), then check:

```bash
# Resolve the skill's own directory (portable across CLIs):
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"
SKILL_DIR="$(cd "$SHMORCH_HOME" && pwd)"
TARGET_ABS="$(cd "${1:-$(pwd)}" && pwd)"
[ "$TARGET_ABS" = "$SKILL_DIR" ] && echo "SELF" || echo "OK"
```

If the result is `SELF`: stop immediately and tell the user:

> `init` cannot be run on the shmorch skill directory itself (`$SHMORCH_HOME`).
> That directory is already a shmorch-managed project with its own live `docs/` — running init
> would overwrite live docs with blank templates.
>
> To work on shmorch's own docs and roadmap, open a session in `$SHMORCH_HOME`
> directly and use the existing `docs/state/plan.md`.

Do not proceed past this point if `SELF`.

---

## Step 1 — Resolve target directory

- If an argument follows "init", expand `~` to the home directory and use that as `TARGET`
- Otherwise, `TARGET` is the current working directory
- `PROJECT_NAME` = the basename of `TARGET`
- `SHMORCH_DIR` = `TARGET/.shmorch`

If `SHMORCH_DIR` already exists and contains an `AGENTS.md`, tell the user Shmorch is already initialized and stop.

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
Copy selectively — agents, workflows, `shmorch-core.md`, and the generated `CLAUDE.md`/`AGENTS.md` are NOT copied:
- `VERSION`, `tools/`, `docs/` — copy in full
- `shmorch-core.md`, `.shmorch/CLAUDE.md`, `.shmorch/AGENTS.md` — **do NOT copy**. `shmorch-core.md` lives only in the skill directory; the project's `.shmorch/CLAUDE.md` and `.shmorch/AGENTS.md` are generated with project-specific content in Step 4 (real skill path + detected stack).
- `.shmorch/agents/` — copy `README.md` and `roles/README.md` only (stubs). Default agents live in the skill at `$SHMORCH_HOME/agents/` and are never copied into projects.
- `.shmorch/workflows/` — copy `README.md` only (stub). Default workflows live in the skill at `$SHMORCH_HOME/workflows/` and are never copied into projects.

Make all `.sh` files executable (chmod +x).

This gives the project empty override directories ready to receive project-specific files, while the skill remains the canonical source for all defaults.

**`templates/.claude/` → `TARGET/.claude/`**
Copy hooks and settings. Skip if files already exist — never overwrite an existing hook.

**`templates/.omp/` → `TARGET/.omp/`**
Copy the omp-native safety hook(s). Skip if files already exist. This gives omp the equivalent of the Claude `.claude/` shell hooks (blocks `rm -rf` / force-push via a `pi.on("tool_call")` module).

**Write `TARGET/.shmorch/home`** — a one-line file holding the resolved absolute skill path (`$SHMORCH_HOME`), so every future session under any CLI resolves the skill location deterministically:
```bash
printf '%s\n' "$SHMORCH_HOME" > "$SHMORCH_DIR/home"
```
Refresh this on every init/sync — it records where the skill lives on *this* machine, which may change.

**`templates/docs/` → `TARGET/docs/`**
Merge carefully — the rule is **skip-if-exists**: copy a file only if no file already exists at that destination path. Never overwrite.

Walk the full `templates/docs/` tree recursively. For each file:
- If the destination path does not exist: copy it.
- If the destination path already exists: skip it silently.

This includes all `index.md` stubs, state file templates, and `.gitkeep` placeholders. The skip-if-exists rule protects existing project content while ensuring new projects get the full skeleton including `index.md` stubs in every docs subdirectory.

**`templates/shmorch.sh` → `TARGET/shmorch.sh`**
Copy only if `TARGET/shmorch.sh` does not exist. Make executable.

**`templates/.githooks/` → `TARGET/.githooks/`**
Copy all files. Skip any that already exist. Make all files executable (`chmod +x`).

After copying, register the hooks path with git — but only if `TARGET` is a git repository:
```bash
git -C "$TARGET" config core.hooksPath .githooks
```
This is idempotent and safe to re-run. It points git at the tracked `.githooks/` directory instead of the default `.git/hooks/`, so the hooks are version-controlled and survive clones. Any developer who runs `shmorch init` (or re-runs it) gets the hooks registered automatically.

After copying, tell the user what was created vs. skipped.

---

## Step 4 — Write .shmorch/AGENTS.md and .shmorch/CLAUDE.md

Shmorch's project instructions live in **`.shmorch/AGENTS.md`** so every agent CLI can load them: Claude Code and omp/Pi reach it through their import chains; Codex / Cursor / opencode / Gemini / Antigravity read `AGENTS.md` too. `.shmorch/CLAUDE.md` is a one-line shim that imports `AGENTS.md`, keeping a single source of truth.

Resolve `SKILL_CORE` — the absolute path to this skill's `shmorch-core.md` (i.e. `$SHMORCH_HOME/shmorch-core.md`). Stamp the real location so the `@` import resolves wherever the skill is installed. When the path is under `$HOME`, write it in `~/`-relative form (Claude Code and omp expand `~/` in `@` imports). Default for a conventional Claude Code install: `~/.claude/skills/shmorch/shmorch-core.md`.

`.shmorch/AGENTS.md` leads with a plain-text **bootstrap** before the import, so CLIs that do NOT expand `@` imports (Codex, Cursor, Antigravity) are still told to read `shmorch-core.md` with their file tool.

Write `SHMORCH_DIR/AGENTS.md` (only if it doesn't exist):
```
<!-- SHMORCH BOOTSTRAP -->
You are in a Shmorch-managed project. Before anything else, read the Shmorch operating
manual at the path on the next line. If your CLI already expanded it inline below,
continue; otherwise read that file now with your file-read tool.

@SKILL_CORE

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

### Branching Discipline

Every track gets its own branch. No direct-to-main commits except hotfixes confirmed by the user.

**Branch naming:** `feat/YYYYMMDD-<slug>` · `fix/YYYYMMDD-<slug>` · `docs/YYYYMMDD-<slug>`

**PR merge strategy:** <!-- merge | squash | rebase — see decisions.md for rationale -->
- `merge` — preserves branch topology in DAG, parallel work visible in graph forever
- `squash` — one commit per PR, granular history lost, topology lost
- `rebase` — granular history preserved, topology lost

**Use:** `gh pr merge --STRATEGY`

### Never Do Without Asking
<!-- fill in -->
```

Then write `SHMORCH_DIR/CLAUDE.md` (only if it doesn't exist) — a thin shim so Claude Code's import chain reaches the same content:
```
@AGENTS.md
```

---

## Step 5 — Wire root context files (AGENTS.md + CLAUDE.md + GEMINI.md)

CLIs auto-load different root files: Claude Code reads root `CLAUDE.md`; omp / Pi / Codex / opencode / Cursor / Antigravity read a standalone root `AGENTS.md` (omp walks up to the repo root but skips dot-directories, so it discovers a **root** `AGENTS.md`, never `.shmorch/AGENTS.md`); Gemini CLI reads `GEMINI.md`. Wire all three. **Each is a pure shim** — a bootstrap comment plus one import, no project content. All substance lives in `.shmorch/AGENTS.md` (single source; no duplication).

For each of `TARGET/AGENTS.md`, `TARGET/CLAUDE.md`, `TARGET/GEMINI.md`:

- `AGENTS.md` and `GEMINI.md` import `@.shmorch/AGENTS.md`; `CLAUDE.md` imports `@.shmorch/CLAUDE.md`.
- **If the file does not exist,** create it (shown for `AGENTS.md`/`GEMINI.md`; use `@.shmorch/CLAUDE.md` in `CLAUDE.md`):
  ```
  <!-- SHMORCH: if your CLI did not expand the import below, read the referenced file now with your file tool. -->
  @.shmorch/AGENTS.md
  ```
- **If it exists,** ensure it contains the matching `@.shmorch/…` import (prepend if missing). Any project content sitting in a root file belongs in `.shmorch/AGENTS.md` — move it there, then leave the root file as the shim.

Cursor also reads `AGENTS.md`, so no separate file is needed; optionally add `.cursor/rules/shmorch.mdc` pointing at `.shmorch/AGENTS.md` if the project uses Cursor rules.

Explain to the user what was done (created vs. amended) for each root file.

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
  .claude/hooks/        — Claude safety hooks (blocks rm -rf, git push --force)
  .omp/hooks/           — omp safety hook (same guards, pi.on tool_call)
  .shmorch/home         — resolved skill path for this machine
  shmorch.sh            — Launcher script (selects your CLI)
  AGENTS.md             — [created/amended → .shmorch/AGENTS.md; omp/Codex/Cursor/opencode/Antigravity]
  CLAUDE.md             — [created/amended → .shmorch/CLAUDE.md; Claude Code]
  GEMINI.md             — [created/amended → .shmorch/AGENTS.md; Gemini CLI]

Launch: bash shmorch.sh   (or start any agent CLI from TARGET — the context chain loads either way)

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
