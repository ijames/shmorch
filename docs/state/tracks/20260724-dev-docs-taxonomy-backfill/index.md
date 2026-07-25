---
status: Active
updated: 2026-07-24
summary: Backfill mechanism design underway. Internal-reference bug found and fixed (tools/workflows/commands/agents still pointed at old docs/ paths). Next: mechanical backfill script + Treeclusion pilot.
---

↑ [tracks/20260724-docs-taxonomy-redesign](../20260724-docs-taxonomy-redesign/index.md)
→ `workflows/auto-update.md` (Step 2.8-style scoped backfill offer) +
`core/documentation.md` § Architecture Changelog (the 2026-07-24 row this track resolves) +
`tools/backfill-docs-taxonomy.sh` (new)

# Track: Docs taxonomy backfill mechanism

**Status:** Active
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

Design resolved 2026-07-24 (see Work log for detail):

- **Hybrid mechanism.** `tools/backfill-docs-taxonomy.sh` does the ~35 mechanical
  `git mv`s (fixed old-path → new-path mapping, same one used for `templates/docs/`).
  A handful of files need agent judgment and are left in place, flagged: per-project
  `decisions.md`/`anti-decisions.md` (split by entry into `product/decisions/` vs
  `technology/decisions/`), `development/notes.md` (fold into
  `technology/development/concepts/` or keep separate), `development/guides/index.md`
  deployment content (→ flat `reference/instructions/deployment.md`, not a subfolder —
  real content doesn't get the "start flat, drop it" treatment the empty template got).
- **Wired into `auto-update.md` Step 2.8**, same `Compat: backfill` yes/no/later opt-in —
  "yes" now runs the script for the mechanical part, then an agent judgment pass, instead
  of today's placeholder text ("migrate manually").
- **Order: Treeclusion first** (smallest footprint — audited 2026-07-24, its `docs/` is
  still the untouched empty scaffold, so it's a near-zero-risk mechanical-only test), then
  shmorch's own `docs/state/` (still unmigrated, low-risk dogfood), then
  appadd/mobos/darkbadge (real content — exercises the judgment pass).

## Work log

### 2026-07-24
Opened as a stub per the deferred-intent-must-have-a-stub-track rule, directly from
`tracks/20260724-docs-taxonomy-redesign`'s closing instructions. No design work done yet.

### 2026-07-24 — design resolved, internal-reference bug found and fixed

Design session with the user resolved all three open questions (see What changes).
Original plan was to dogfood on shmorch's own `docs/state/` first; revised to
Treeclusion after the user pointed out it has the smallest footprint — confirmed by
audit: `development/decisions.md`, `anti-decisions.md`, `notes.md`,
`cognitive-architecture.md` are all still empty template stubs there, so migrating it
exercises only the mechanical path, not the judgment path.

Before writing the backfill script, discovered a bigger, more urgent problem while
scoping it: `tools/*.sh`, `workflows/*.md`, `commands/*.md`, and `agents/**` — all read
live from `$SHMORCH_HOME` for *every* project, new or legacy — still had ~250 references
to the old `docs/state/`, `docs/architecture/`, `docs/development/` paths. This was
broken for brand-new `/shmorch init` projects too, not just already-provisioned ones,
because the original `20260724-docs-taxonomy-redesign` track only updated
`core/documentation.md`, `shmorch-core.md`, and `templates/docs/` — it missed the actual
operational tooling. User confirmed: these are real operational paths (scripts `git add`
and `find` against them, workflows instruct agents to read/write them at literal paths),
not just links — and asked to fix them now, mechanically, rather than build a
legacy-fallback path-resolution shim (not worth the complexity for the five known
affected projects). Fixed via a mechanical sed sweep plus hand-fixes for the sites sed
couldn't safely rewrite: the `EXPECTED_DOCS`/scaffold-diff arrays in `auto-update.md` and
`self-improve.md` (rewritten to the full new directory list), `tools/commit-session-state.sh`
(the naive `decisions.md` → prose-placeholder swap broke its bash array syntax; rewritten
as a proper loop over both `docs/product/decisions/` and `docs/technology/decisions/`),
and a handful of `docs/development/decisions.md` prose references across workflows/agents
rewritten to `docs/{product,technology}/decisions/` (topic-appropriate). Left untouched,
correctly: `core/documentation.md`'s dated Architecture Changelog rows (historical record
of what a rule said on that date) and shmorch's own still-unmigrated `docs/state/**`
content (that's what this track's actual backfill work migrates). `VERSION` bumped to
`20260724.03` for this fix, committed separately from the backfill script itself.

### 2026-07-24 — backfill script written and piloted on Treeclusion

Wrote `tools/backfill-docs-taxonomy.sh`: a fixed old-path → new-path mapping (23 mechanical
`git mv`s, directories included) plus a `JUDGMENT` list of paths with real content and no
1:1 new home, left in place and reported rather than moved. `VERSION` bumped to `20260724.04`.

Ran it against Treeclusion (`/Users/james/Projects/treeclusion`, the smallest-footprint
pilot picked per the order above): all 23 mappings applied cleanly as `git mv` renames
(verified via `git status` — all show as `R`, not delete+add, so history is preserved),
empty leftover dirs (`docs/architecture/`, `docs/development/`, `docs/to_review/`) were
removed. Five judgment-flagged files correctly left untouched: `architecture/decisions.md`,
`development/decisions.md`, `development/anti-decisions.md`, `development/notes.md`,
`development/guides/index.md` — plus `product/cognitive-architecture.md`, which turned out
to have real content (not an empty stub like the audit assumed) and has no direct mapping
target; added it to the script's judgment list, fixed a report-formatting bug the parenthetical
in its message caused (line matching against a path containing `(...)` silently failed to
print). Changes are staged in Treeclusion's working tree, not yet committed there — pending
user confirmation before committing in another repo, and before the judgment-file pass runs.

Not yet done: wire `tools/backfill-docs-taxonomy.sh` into `workflows/auto-update.md` Step 2.8
(replace the "migrate manually" placeholder), update the 2026-07-24 Architecture Changelog
row's "Backfill scope" cell in `core/documentation.md` to point at the script, and the
judgment-file pass on Treeclusion itself.
