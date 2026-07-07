# Workflow and Agent Override Pattern

Default workflows and agent roles live in the **skill** — they are not copied into projects. Projects contain only overrides and additions.

## Resolution Order

**Workflows:**
1. `.shmorch/workflows/<name>.md` — project override (if present)
2. `$SHMORCH_HOME/workflows/<name>.md` — skill default (fallback)

**Agent roles:**
1. `.shmorch/agents/roles/<name>.md` — project override (if present)
2. `$SHMORCH_HOME/agents/roles/<name>.md` — skill default (fallback)

**Core doctrine:**
1. `$SHMORCH_HOME/core/<name>.md` — skill only; not overridden per-project

Both workflows and roles may reference `core/` files as needed for a specific task.

---

## Override Pattern — Extend (preferred)

Project workflow files are thin subclasses of skill defaults. They declare only the delta — added steps, tightened constraints, domain-specific rules — and inherit everything else from the skill.

```markdown
# Extends: $SHMORCH_HOME/workflows/build.md

> Read the skill default first: `$SHMORCH_HOME/workflows/build.md`
> Each section below replaces the matching section. Everything else follows the skill default.

## Step 1 — Branch setup (project override)
...
```

Claude reads the base first, then applies declared overrides. Undeclared sections follow the skill default automatically.

---

## Complete Supersession (last resort)

Rewrite the file entirely only when the project's approach is so fundamentally different that inheriting skill defaults would actively mislead. If you find yourself rewriting more than half the file, reconsider: the generic parts probably belong in the skill.

**To restore a skill default:** delete the project-local file.

---

## Graduation Rule

When a project-specific addition proves useful across sessions and would benefit any project, it belongs in the skill — not the project override. Self-improve flags this; when confirmed, move the content to the skill and thin the project file back down. Project files should trend toward empty over time as their good ideas graduate.

---

## Fat-Copy Anti-Pattern

A project workflow file that is a full copy of the skill default (not using Extends) is a maintenance liability — it will silently diverge as the skill evolves. Self-improve detects these and flags them for trimming.

Project override directories (`.shmorch/workflows/`, `.shmorch/agents/roles/`) are created empty by `init` with README stubs explaining this pattern.
