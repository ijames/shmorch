# Workflow: auto-update

Bring this project's shmorch installation up to date with the current skill version (skill → project direction).

> Provisioning phase for `go` (state **BEHIND**) — `go` routes here when the project is behind the skill. Also directly invokable as `/shmorch sync` (aliases: `update`, `auto-update`).

## When to use
- Automatically triggered by `go` when a VERSION mismatch is detected
- Manually anytime via `/shmorch auto-update`
- After the skill has been updated externally

## Inputs
- `.shmorch/VERSION` — project's current version
- `$SHMORCH_HOME/VERSION` — latest skill version
- `$SHMORCH_HOME/templates/.shmorch/` — skill template files
- `$SHMORCH_HOME/core/documentation.md` § Architecture Changelog — rule changes that may need a docs-content backfill (Step 2.8)

## Roles
- None — runs inline

---

## Step 0 — Resolve skill location

Resolve and export `$SHMORCH_HOME` (see `core/portability.md`) before anything else — this workflow may run standalone (`/shmorch sync`):
```bash
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$(cat .shmorch/home 2>/dev/null || true)"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"
export SHMORCH_HOME
```

---

## Step 1 — Version check

```bash
PROJECT_VERSION=$(cat .shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
SKILL_VERSION=$(cat "$SHMORCH_HOME/VERSION" 2>/dev/null | tr -d '[:space:]')
echo "Project: $PROJECT_VERSION"
echo "Skill:   $SKILL_VERSION"
```

If versions match: tell the user "Already up to date ($PROJECT_VERSION)." and stop.

---

## Step 2 — Structural scaffold diff

Check whether the project is missing any directories or seed files that the current skill template defines. Do not touch files that already exist.

```bash
# Directories expected by current template
for d in \
  docs/state docs/state/tracks docs/state/schedule \
  docs/product docs/development docs/architecture docs/reference \
  docs/development/guides docs/development/testing \
  .shmorch/tools .shmorch/workflows .shmorch/agents/roles .claude/hooks; do
  [ -d "$d" ] || echo "MISSING DIR: $d"
done

# Seed files expected (only if their parent dir exists)
# Note: docs/tracks/ does NOT exist — tracks live in docs/state/tracks/YYYYMMDD-<name>/
for f in \
  docs/state/schedule/README.md \
  .shmorch/agents/TASK-PROTOCOL.md; do
  [ -f "$f" ] || echo "MISSING FILE: $f"
done
```

If anything is missing: list it, then ask "Create missing scaffold? (yes/no)". If yes, copy from skill templates — never overwrite existing files.

---

## Step 2.1 — Reverse scaffold check

Check what exists in `docs/` that isn't in the canonical template. These may be legitimate project-specific dirs, or they may indicate the template has drifted from actual convention.

```bash
EXPECTED_DOCS="docs docs/state docs/state/tracks docs/state/schedule docs/product docs/development docs/architecture docs/reference docs/development/guides docs/development/testing docs/development/code-styleguides docs/to_review"
LOG=".shmorch/project_docs_log.md"
LOGGED=""
[ -f "$LOG" ] && LOGGED=$(grep -v '^#' "$LOG" 2>/dev/null)
find docs -maxdepth 2 -mindepth 1 -type d | grep -v "^docs/state/tracks/" | sort | while read d; do
  echo "$EXPECTED_DOCS" | grep -qw "$d" && continue
  echo "$LOGGED" | grep -qxF "$d" && continue
  echo "$LOGGED" | while read logged; do [ -n "$logged" ] && [[ "$d" == "$logged"/* ]] && exit 0; done && continue
  echo "UNLISTED DIR: $d"
done
```

If any `UNLISTED DIR` entries appear:
1. List them to the developer
2. For each, ask: is this project-specific (append to `.shmorch/project_docs_log.md`) or a convention that should be added to the canonical scaffold?
3. If project-specific: append the top-level dir to `.shmorch/project_docs_log.md` (one path per line; logging a top-level dir covers everything nested under it — no need for separate lines).
4. If it should be canonical: note it — propose adding it to the scaffold list in this file as part of Step 6, along with a PR to the skill.

Do **not** flag `docs/state/tracks/YYYYMMDD-*` subdirectories — those are per-project and expected to vary.

---

## Step 2.3 — Legacy shmorch/ folder migration

Check if the project has an old-style `shmorch/` directory (without the dot) instead of `.shmorch/`:

```bash
[ -d "shmorch" ] && [ ! -d ".shmorch" ] && echo "LEGACY shmorch/ detected" || echo "ok"
```

If `LEGACY shmorch/ detected`: tell the user:
> "This project uses the old `shmorch/` directory. Current convention is `.shmorch/`. Rename it now? (yes/no)"

If yes:
1. `mv shmorch .shmorch`
2. If `CLAUDE.md` contains `@shmorch/CLAUDE.md`, replace with `@.shmorch/CLAUDE.md`
3. List any remaining references: `grep -r "shmorch/" . --include="*.sh" --include="*.json" --include="*.md" | grep -v ".shmorch" | grep -v "skills/shmorch"` — tell the user to review them.

If no: skip without comment.

---
## Step 2.4 — Multi-CLI context-chain migration

Bring the project onto the portable, multi-CLI context chain (`core/portability.md`). Every item is idempotent — skip any that is already in place. This is what propagates the portability upgrade to repos initialized before it existed.

**a. Refresh `.shmorch/home`** — record where the skill lives on this machine:
```bash
printf '%s\n' "$SHMORCH_HOME" > .shmorch/home
```

**b. Enforce single-source `.shmorch/AGENTS.md` (no duplication).** `.shmorch/AGENTS.md` is the *only* context file that carries substance; `.shmorch/CLAUDE.md` must be the one-line shim `@AGENTS.md`. Reconcile whatever state the repo is in:
- **AGENTS.md missing, CLAUDE.md is a full file (old inline layout):** create `.shmorch/AGENTS.md` from the CLAUDE.md body (everything after its `@…/shmorch-core.md` import), prefixed with the bootstrap block and the import stamped to `$SHMORCH_HOME/shmorch-core.md` (`~/`-relative when under `$HOME`) — shape per `init.md` Step 4. Then overwrite `.shmorch/CLAUDE.md` with the shim `@AGENTS.md`.
- **CLAUDE.md is already `@AGENTS.md`:** nothing to migrate — just refresh AGENTS.md's stamped import path if the skill location changed.
- **Both exist as full files (duplication — the case to fix strictly):** treat `.shmorch/AGENTS.md` as authoritative. Diff the two; if `.shmorch/CLAUDE.md` holds any substance not already in `.shmorch/AGENTS.md`, migrate it into `.shmorch/AGENTS.md` (confirm the merge with the user when they differ). Then overwrite `.shmorch/CLAUDE.md` with the shim `@AGENTS.md`. Never leave two files carrying the same overrides.

**c. Root context files — pure shims (no duplication).** Root files carry no substance: a bootstrap comment plus one import, nothing else. For each of root `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`: if missing, create the shim (`AGENTS.md`/`GEMINI.md` → `@.shmorch/AGENTS.md`; `CLAUDE.md` → `@.shmorch/CLAUDE.md`) with the bootstrap comment, per `init.md` Step 5. If a root file exists and carries substance beyond the import (project notes/overrides), migrate that substance into `.shmorch/AGENTS.md` (confirm with the user), then reduce the root file to the shim. If it merely lacks the import line, prepend it.

**d. omp safety hook.** If `.omp/hooks/pre/safety.ts` is missing, copy it from `$SHMORCH_HOME/templates/.omp/hooks/pre/safety.ts`.

**e. Launcher.** If `shmorch.sh` is the old Claude-only launcher (runs `claude` with no `SHMORCH_CLI` handling), offer to replace it with the current multi-CLI `$SHMORCH_HOME/templates/shmorch.sh`. Default yes — it is generated, not hand-edited.

Report each action taken or skipped.

---


## Step 2.5 — Artifact scan

Check for migration leftovers that may have been created by a previous kustomize update or manual edit session. These are safe to delete but require confirmation.

```bash
# Known migration artifact patterns inside the project
find .shmorch/ -maxdepth 3 \( \
  -name "*.prev.sh" -o \
  -name "*.backup" -o \
  -name "*.bak" -o \
  -regex ".*/build-[0-9]\{8\}\.md" \
\) 2>/dev/null

# Also check repo root for *.prev.sh
find . -maxdepth 1 -name "*.prev.sh" 2>/dev/null
```

If any matches: list them and ask "Delete migration artifacts? (yes/no)". If yes, delete. If no, skip without comment.

---

## Step 2.7 — Orphaned project-local tool scripts

Since version `20260516.01`, all shmorch tool scripts live in `$SHMORCH_HOME/tools/` and are called via absolute path. Projects no longer need local copies.

Check for scripts that should now be removed from the project:

```bash
ORPHANED_TOOLS=(
  timelog.sh duration.sh checkpoint.sh vacuum.sh run-task.sh parse-status.sh
  check-session-state.sh commit-session-state.sh check-self-improve-gate.sh
)
FOUND=()
for f in "${ORPHANED_TOOLS[@]}"; do
  [ -f ".shmorch/tools/$f" ] && FOUND+=("$f")
done
if [ ${#FOUND[@]} -gt 0 ]; then
  echo "ORPHANED: ${FOUND[*]}"
else
  echo "clean"
fi
```

If any are found: tell the user:
> "These tool scripts are now bundled in the skill and no longer needed in `.shmorch/tools/`: `<list>`. Remove them? (yes/no)"

If yes:
```bash
for f in "${FOUND[@]}"; do git rm --force ".shmorch/tools/$f" 2>/dev/null || rm -f ".shmorch/tools/$f"; done
```

If `.shmorch/tools/` is now empty (only README.md or nothing), note that it is now a workflows/agents override directory only — tools live in the skill.

If no: skip without comment.

---

## Step 2.8 — Architecture backfill

`core/documentation.md` doctrine isn't mirrored into projects — it's read live from
`$SHMORCH_HOME`, so rule text is always current automatically. What can't self-update is
docs *content* written under an older rule. Its `## Architecture Changelog` table is the
list of rule changes that invalidate existing content; check it against this project's
pre-update `.shmorch/VERSION` date:

```bash
PROJECT_DATE="${PROJECT_VERSION%%.*}"   # YYYYMMDD portion, captured before Step 6 overwrites VERSION
```

Read `core/documentation.md`'s Architecture Changelog table. For every row with `Compat:
backfill` and a date **after** `$PROJECT_DATE`: this project predates that rule.

For each such row, ask (one at a time, do not batch):
> "Docs architecture changed since your last sync: '<rule>' (<date>). Existing docs written
> before then don't conform. Backfill now? (yes/no/later)"

- **no/later** — skip; note it in the Step 7 report so it isn't silently forgotten.
- **yes** — run a scoped pass using that row's `Backfill scope` cell as the exact instruction
  (e.g. "add front-matter to any `docs/state/*.md` file that lacks one"). Scope is always
  bounded to what that one row describes — never a general docs audit. Read each affected
  file before writing; derive required values (e.g. `summary`) from actual content, never
  invent them. Report each file touched.

This is deliberately per-row and per-project-opt-in, not a bulk "restructure everything"
pass — each changelog entry is small and reviewable on its own.

---

## Step 2.9 — Hook sync

Ensure the project's `.githooks/` and `.claude/hooks/` files are in sync with the skill template and are executable. This mirrors what `init` does on first setup.

**Git hooks (`.githooks/`)**

```bash
SKILL_HOOKS="$SHMORCH_HOME/templates/.githooks"
PROJECT_HOOKS=./.githooks

# Check if .githooks/ exists in project
[ -d "$PROJECT_HOOKS" ] || echo "MISSING: .githooks/ directory"

# Diff skill hooks vs project hooks
if [ -d "$PROJECT_HOOKS" ] && [ -d "$SKILL_HOOKS" ]; then
  diff -rq "$SKILL_HOOKS" "$PROJECT_HOOKS" 2>/dev/null || true
fi

# Check executability
find "$PROJECT_HOOKS" -type f 2>/dev/null | while read f; do
  [ -x "$f" ] || echo "NOT EXECUTABLE: $f"
done
```

For each file reported as `Only in $SKILL_HOOKS` (new hook in skill, missing from project):
- Offer to copy it. Default yes.

For each file reported as differing:
- Show the diff. Classify as `generic-improvement` or `conflict` using the same rules as Step 4.
- Offer to apply generic improvements automatically.

For each `NOT EXECUTABLE` file:
- Fix silently: `chmod +x <file>`

After any hook file changes, re-register the hooks path (idempotent):
```bash
git config core.hooksPath .githooks
```

**Claude Code hooks (`.claude/hooks/`)**

```bash
SKILL_CLAUDE_HOOKS="$SHMORCH_HOME/templates/.claude/hooks"
PROJECT_CLAUDE_HOOKS=./.claude/hooks

[ -d "$PROJECT_CLAUDE_HOOKS" ] || echo "MISSING: .claude/hooks/ directory"

if [ -d "$PROJECT_CLAUDE_HOOKS" ] && [ -d "$SKILL_CLAUDE_HOOKS" ]; then
  diff -rq "$SKILL_CLAUDE_HOOKS" "$PROJECT_CLAUDE_HOOKS" 2>/dev/null || true
fi

find "$PROJECT_CLAUDE_HOOKS" -type f 2>/dev/null | while read f; do
  [ -x "$f" ] || echo "NOT EXECUTABLE: $f"
done
```

Apply the same rules as git hooks above: offer to copy new files, show diffs for changed files, fix executability silently. After copying any new hook, also add the corresponding entry to `.claude/settings.json` under `hooks` — copy the entry from `templates/.claude/settings.json` if it isn't already present.

---

## Step 3 — File diff (bash first)

Run a concrete diff between the skill template and the project's shmorch files. This is the ground truth — semantic analysis comes after, not instead of, this.

```bash
SKILL="$SHMORCH_HOME/templates/.shmorch"
PROJECT=./.shmorch

# What files differ between skill template and project?
# Note: shmorch-core.md is skill-only (not in templates/.shmorch) — not compared here.
diff -rq "$SKILL" "$PROJECT" \
  --exclude="CLAUDE.md" \
  --exclude="VERSION" \
  --exclude="*.json" \
  2>/dev/null || true
```

Capture the output. Files listed as `Only in $SKILL` are new in the skill but missing from the project. Files listed as `Files ... differ` have changed content.

---

## Step 4 — Classify differences

For each file reported as different or missing:

Read both versions (skill template + project copy). Classify the difference:

| Class | Meaning | Action |
|---|---|---|
| `new-in-skill` | File exists in skill template, not in project | Offer to copy |
| `generic-improvement` | Skill version has a change that would benefit any project | Offer to apply |
| `project-specific` | Project version has customizations the skill doesn't know about | Preserve — note for CLAUDE.md |
| `conflict` | Both sides changed the same section incompatibly | Ask developer to decide |

Skip: `docs/state/**`, `.shmorch/AGENTS.md`, `.shmorch/CLAUDE.md`, `.shmorch/VERSION` — never touch these.

Only read files that `diff` flagged. Do not analyze files that are identical.

---

## Step 5 — Present and confirm

Show a summary table:

```
File                              | Class               | Proposed action
----------------------------------|---------------------|----------------
.shmorch/agents/TASK-PROTOCOL.md   | new-in-skill        | Copy from skill
.shmorch/workflows/analyze.md      | generic-improvement | Show diff, offer to apply
.shmorch/agents/roles/sprinter.md  | new-in-skill        | Copy from skill
.shmorch/workflows/build.md        | conflict            | Ask developer
```

For `generic-improvement` and `conflict` entries: show the specific diff (not the whole file — just the changed sections). Ask the developer to confirm each one.

For `new-in-skill`: just copy without showing full content unless asked.

For `project-specific`: note it. Ask if the developer wants to extract it to `.shmorch/AGENTS.md` so the generic file can be cleanly updated. Never force this.

---

## Step 6 — Apply confirmed changes

For each confirmed item: copy or patch the file.

Then update VERSION in the project:

```bash
SKILL_VERSION=$(cat "$SHMORCH_HOME/VERSION" | tr -d '[:space:]')
echo "$SKILL_VERSION" > .shmorch/VERSION
echo "Project shmorch updated to $SKILL_VERSION"
```

---

## Step 7 — Report

List what was updated, what was skipped, and any project-specific customizations noted.
If any `project-specific` content was identified but not extracted: remind the developer to consider moving it to `.shmorch/AGENTS.md` so future updates don't require manual conflict resolution.
