# Shmorch — Project Docs

This directory is the live project documentation **for the shmorch skill itself**.
It follows the same skeleton that shmorch creates for any project it manages.

## Boundary

| Path | Purpose |
|---|---|
| `docs/` (this directory) | Live docs for shmorch-as-project — roadmap, backlog, architecture decisions about the tool |
| `templates/docs/` | Blank stubs seeded to new repos when `/shmorch init` runs — never edited as live docs |

Changes here do **not** bump `VERSION`. Version tracks skill behaviour changes, not internal project documentation.

## Structure (filling in over time)

- `docs/state/plan.md` — shmorch backlog and in-flight work
- `docs/state/context.md` — project identity (to be populated via curated init)
- `docs/architecture/` — design decisions for shmorch internals
- `docs/development/decisions.md` — permanent record of all shmorch design choices

## Working on Shmorch

Open a session in `~/.claude/skills/shmorch/` directly. Do not run `/shmorch init` here —
that is guarded. Work with the existing state files and follow the skill change workflow
in `shmorch-core.md` for any changes that affect skill behaviour.
