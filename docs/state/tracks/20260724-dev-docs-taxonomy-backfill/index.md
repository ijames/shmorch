---
status: Blocked
updated: 2026-07-24
summary: Stub — backfill mechanism for migrating already-provisioned projects (appadd, mobos, darkbadge, shmorch's own docs/) onto the new docs taxonomy. Not designed yet, blocked on being picked up.
---

↑ [tracks/20260724-docs-taxonomy-redesign](../20260724-docs-taxonomy-redesign/index.md)
→ `workflows/auto-update.md` (Step 2.8-style scoped backfill offer) +
`core/documentation.md` § Architecture Changelog (the 2026-07-24 row this track resolves)

# Track: Docs taxonomy backfill mechanism

**Status:** Blocked — pending design
**Opened:** 2026-07-24
**Domain:** Documentation architecture

## Why

`tracks/20260724-docs-taxonomy-redesign` replaced Shmorch's top-level `docs/` skeleton
(`architecture/development/product/reference/state/to_review` →
`product/technology/reference/project/inbox`) and implemented it in `templates/docs/`,
the scaffold `init` copies into new projects. That track explicitly did **not** solve how
already-provisioned projects — ones that already have a `docs/` tree built on the old
skeleton — get migrated. Per the user's instruction: split into its own track, worked
before actual backfill implementation, not solved at design-close time.

At least three known live projects need this: `AppAdd/appadd/docs/`, `MoBoS/mobos/docs/`,
and shmorch's own `docs/state/` (still on the old `state/` naming — see
`core/documentation.md` § Architecture Changelog, 2026-07-24 row, `Compat: backfill`).
`DarkBadge` is a fourth candidate, not yet audited for this specific migration.

## What changes

Not yet decided — this is a stub. Open questions to resolve before design starts:

- Is this a scripted mechanical rename (git mv old path → new path per a fixed mapping)
  or does it need per-project judgment calls the way the original template restructure
  did (e.g. deciding whether a project's `development/notes.md` folds into `concepts/` or
  stays separate, genericizing project-specific content that leaked into docs)?
- How does `auto-update.md` Step 2.8 offer this — same `Compat: backfill` mechanism as
  other Architecture Changelog rows, or does the scale of this one (whole-tree rename, not
  a localized addition) need a dedicated workflow step?
- Order of migration across the known projects — shmorch's own `docs/state/` first (dogfood
  the mechanism before offering it to managed projects), or a managed project first (real
  external validation)?

## Work log

### 2026-07-24
Opened as a stub per the deferred-intent-must-have-a-stub-track rule, directly from
`tracks/20260724-docs-taxonomy-redesign`'s closing instructions. No design work done yet.
