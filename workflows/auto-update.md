# Workflow: auto-update

Bring this project's shmorch installation up to date with the current skill version (skill → project direction).

## When to use
- Automatically triggered by `go` when a VERSION mismatch is detected
- Manually anytime via `/shmorch auto-update`
- After the skill has been updated externally

## Inputs
- `.shmorch/VERSION` — project's current version
- `~/.claude/skills/shmorch/VERSION` — latest skill version
- `~/.claude/skills/shmorch/templates/.shmorch/` — skill template files

## Roles
- None — runs inline

---

## Step 1 — Version check

```bash
PROJECT_VERSION=$(cat .shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
SKILL_VERSION=$(cat ~/.claude/skills/shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
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
EXPECTED_DOCS="docs docs/state docs/state/tracks docs/state/schedule docs/product docs/development docs/architecture docs/reference docs/development/guides docs/development/testing"
find docs -maxdepth 2 -mindepth 1 -type d | grep -v "^docs/state/tracks/" | sort | while read d; do
  echo "$EXPECTED_DOCS" | grep -qw "$d" || echo "UNLISTED DIR: $d"
done
```

If any `UNLISTED DIR` entries appear:
1. List them to the developer
2. For each, ask: is this project-specific (skip) or a convention that should be added to the canonical scaffold?
3. If it should be canonical: note it — propose adding it to the scaffold list in this file as part of Step 6, along with a PR to the skill.

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

Since version `20260516.01`, all shmorch tool scripts live in `~/.claude/skills/shmorch/tools/` and are called via absolute path. Projects no longer need local copies.

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

## Step 3 — File diff (bash first)

Run a concrete diff between the skill template and the project's shmorch files. This is the ground truth — semantic analysis comes after, not instead of, this.

```bash
SKILL=~/.claude/skills/shmorch/templates/.shmorch
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

Skip: `docs/state/**`, `.shmorch/CLAUDE.md`, `.shmorch/VERSION` — never touch these.

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

For `project-specific`: note it. Ask if the developer wants to extract it to `.shmorch/CLAUDE.md` so the generic file can be cleanly updated. Never force this.

---

## Step 6 — Apply confirmed changes

For each confirmed item: copy or patch the file.

Then update VERSION in the project:

```bash
SKILL_VERSION=$(cat ~/.claude/skills/shmorch/VERSION | tr -d '[:space:]')
echo "$SKILL_VERSION" > .shmorch/VERSION
echo "Project shmorch updated to $SKILL_VERSION"
```

---

## Step 7 — Report

List what was updated, what was skipped, and any project-specific customizations noted.
If any `project-specific` content was identified but not extracted: remind the developer to consider moving it to `.shmorch/CLAUDE.md` so future updates don't require manual conflict resolution.
