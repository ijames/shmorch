# .shmorch/agents/roles — Project Overrides

Default roles live in the skill at `~/.claude/skills/shmorch/agents/roles/`.
This directory holds project-specific role overrides and additions only.

**Resolution:** Shmorch checks here first. If a file is absent, the skill default is used.

---

## Two override patterns

### 1. Complete supersession
Use when the role needs a fundamentally different persona or set of rules for this project.

```bash
cp ~/.claude/skills/shmorch/agents/roles/analyst.md .shmorch/agents/roles/analyst.md
# Rewrite entirely
```

### 2. Extend (recommended for partial changes)
Use when you want to add domain knowledge, constraints, or focus areas
on top of the standard role — without duplicating the base behavior.

```markdown
# Extends: ~/.claude/skills/shmorch/agents/roles/analyst.md

> Read the skill default first: `~/.claude/skills/shmorch/agents/roles/analyst.md`
> Then apply the additions below. These supplement — not replace — the base role
> unless a section heading matches one in the skill default.

## Domain knowledge — MoBoS

When analyzing PHP code in this project:
- The service layer is at `htdocs/service/` — Biz, Order, Market, Trader, Account
- Tests use PHPUnit at `htdocs/tests/`
- Flag any service method without a corresponding test as [GAP]
```

---

## Add a project-specific role

Create a new file — it won't conflict with skill defaults.
Reference it in Task prompts using the standard resolution pattern:

```
Read your role: check .shmorch/agents/roles/<name>.md first;
if not present, use ~/.claude/skills/shmorch/agents/roles/<name>.md.
```
