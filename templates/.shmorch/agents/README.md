# .shmorch/agents — Project Overrides

Default agents live in the skill at `~/.claude/skills/shmorch/agents/`.
This directory holds project-specific overrides only.

**`TASK-PROTOCOL.md`** — the Task call contract. Skill default at
`~/.claude/skills/shmorch/agents/TASK-PROTOCOL.md`. Override here to change
Task call conventions project-wide (rare — usually role overrides are sufficient).

**`orchestrator.md`** — override here to change how the main agent decomposes
and coordinates work for this project.

**`roles/`** — see `roles/README.md` for the override patterns.
