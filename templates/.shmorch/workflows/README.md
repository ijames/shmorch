# .shmorch/workflows — Project Overrides

Default workflows live in the skill at `~/.claude/skills/shmorch/workflows/`.
This directory holds project-specific overrides and additions only.

**Resolution:** Shmorch checks here first. If a file is absent, the skill default is used.

---

## Two override patterns

### 1. Complete supersession
Use when the workflow is fundamentally different for this project — not just a tweak.
Create a file with the same name and write it entirely from scratch.

```bash
cp ~/.claude/skills/shmorch/workflows/navigate.md .shmorch/workflows/navigate.md
# Rewrite entirely for project-specific navigation model
```

### 2. Extend (recommended for partial changes)
Use when you want to add steps, tighten a checklist, or customize one phase
without duplicating everything else.

Create the file with an `Extends:` header:

```markdown
# Extends: ~/.claude/skills/shmorch/workflows/build.md

> Read the skill default first: `~/.claude/skills/shmorch/workflows/build.md`
> Then apply the overrides below. Each section here replaces the matching
> section in the skill default. Everything else follows the skill default.

## Step 4 — Definition of Done (project additions)

In addition to the standard DoD:
- Run `<project-specific test command>`
- Check `<project-specific lint or type check>`
```

Claude reads the base first, then applies only the declared overrides.
You stay in sync with skill updates to all the other steps automatically.

---

## Add a project-specific workflow

Create a new file with any name — it won't conflict with skill defaults.
Reference it from `.shmorch/CLAUDE.md` or call it explicitly in a session.
