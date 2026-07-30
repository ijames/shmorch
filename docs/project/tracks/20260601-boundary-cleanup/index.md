---
status: Open
updated: 2026-06-01
summary: Layer boundary cleanup across core/role/workflow/command — define exclusive ownership per layer, move violators. Depends on core-breakup track.
---

↑ [Shmorch Plan](../../plan.md)
→ `core/index.md` + affected `workflows/` and `commands/` files

# Track: Core / role / workflow / command boundary cleanup

**Status:** Open
**Opened:** 2026-06-01
**Domain:** Skill architecture

## Why

The four layers (core, role, workflow, command) have content living in the wrong layer, causing collision and duplication:
1. Dimension content (observability, progressive delivery, etc.) is high-level principle but lives in core — it should be reachable from role and workflow docs when relevant, not only from core
2. Build-phase rules that belong in `workflows/build.md` drift into core
3. Commands that dispatch to workflows sometimes carry logic that belongs in the workflow

The layer boundary problem and the include/reference problem (graph-first docs track) are the same problem at different scales.

## What changes

- Define what each layer exclusively owns
- Identify current violations (content in wrong layer)
- Move content to the right layer

Depends on: core-breakup track (prerequisite — can't restructure layers while core is still a monolith).

## Work log

### 2026-06-01
Identified during DarkBadge session alongside core-breakup. Both tracks address the same structural debt from different angles.
