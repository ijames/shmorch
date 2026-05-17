# README Documentation

Initial source of truth for all project knowledge. Every folder has an `index.md`; every document links back up.

---

## Layers

| Folder | Purpose |
|--------|---------|
| [product/](product/index.md) | Intent — what the system does and why; functional specs, UI, business rules |
| [development/](development/index.md) | Technical design — how it's built; schemas, interfaces, implementation notes |
| [architecture/](architecture/index.md) | Stable decisions — constraining principles, ADRs, system structure |
| [reference/](reference/index.md) | API surface — Schwab endpoint schemas, config keys, generated docs |
| [guides/](guides/index.md) | Operational — deploy, configure, contribute |
| [tracks/](tracks/index.md) | Completed track histories — graduated from state/ on close |
| [state/](state/index.md) | Active work — Shmorch-managed; plan, spec, decisions in flight, active tracks |
| [archive/](archive/README.md) | Old material kept for reference |
| [to_review/](to_review/README.md) | Inbox — drop specs/plans here for Shmorch to integrate |

---

## Quick Navigation

- **What's happening now?** → [state/plan.md](state/plan.md)
- **How does the system work?** → [architecture/system-overview.md](architecture/system-overview.md)
- **Tech stack?** → [development/tech-stack.md](development/tech-stack.md)
- **Deploy/CI?** → [guides/index.md](guides/index.md)
- **Decisions log?** → [architecture/decisions.md](architecture/decisions.md)

---

## Key Files in Codebase

### Entry Points

| File | Purpose |
|------|---------|

### Core Services

| File | Purpose |
|------|---------|

### Models

| File | Purpose |
|------|---------|

### API Endpoints

| File | Purpose |
|------|---------|

---

## Hosting

| Host | OS / PHP | Config |
|------|----------|--------|

⚠️ **Config sync risk:** The `[trading]` and `[services.schwab.api]` sections must be identical across all configs. See [guides/](guides/index.md).
