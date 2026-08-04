# Shmorch — Documentation Index

> Start here. Every document in this project is reachable from this page.
> Permanent docs live under `docs/`. In-flight work lives under `docs/project/`.
> This is shmorch's own self-hosted project doc tree — see `docs/README.md` for the
> boundary between this (live docs for shmorch-as-project) and `templates/docs/`
> (blank stubs seeded into other repos by `/shmorch init`).

---

## What This Project Is

Shmorch is an autonomous development orchestrator — a Claude Code (and other-CLI)
skill that manages a project's docs, backlog, and multi-agent work through a set of
commands (`init`, `resume`, `go`, `wrap`, `auto-update`, ...), workflows, and role
doctrine. This repo is shmorch developing on itself.

---

## Permanent Documentation

### Product
Not yet scaffolded — no `docs/product/` in this repo. Shmorch's "product" is the
skill itself; vision/strategy for it currently lives in `docs/project/plan/` (backlog)
rather than a dedicated product section. ⚠️ _TBD_

### [Technology](technology/index.md)
How it's built — architecture and internal design decisions for shmorch itself.

### Reference
No `docs/reference/index.md` yet (single file so far): [learning.md](reference/learning.md) — concepts logged as the developer encounters them, one entry per concept.

---

## In-Flight State

> `docs/project/` — work in progress, changes daily. On close, knowledge graduates
> to the permanent sections above.

- [Plan](project/plan/index.md) — Backlog for the shmorch skill itself, one file per item
- [Session](project/session.md) — Cross-session continuity notes
- [Timelog](project/timelog.md) — Session and task timing
- [Pre-planning](project/pre-planning.md) — Early scoping notes
- [Tracks](project/index.md) — Work-in-progress and closed track history

No `spec.md`, `context.md`, `process/`, or `schedule/` in this repo yet — this
project has never had the full `init`/`auto-update` scaffold applied to itself.

## Inbox

- [inbox/](inbox/index.md) — drop specs/plans here for Shmorch to integrate

---

## Document Health

| Symbol | Meaning |
|---|---|
| _(no marker)_ | Stable — reflects current reality |
| ⚠️ _draft_ | Written but not reviewed/confirmed |
| ⚠️ _TBD_ | Placeholder — decision pending |
| ⚠️ _blocked_ | Cannot be finalized until a dependency resolves |

---

↓ children: [technology/](technology/index.md), [reference/learning.md](reference/learning.md), [project/](project/index.md), [inbox/](inbox/index.md)
