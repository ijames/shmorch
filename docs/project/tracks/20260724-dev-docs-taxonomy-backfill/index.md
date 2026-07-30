---
status: Closed
updated: 2026-07-30
summary: Backfill mechanism built, piloted on Treeclusion, wired into auto-update.md, and now run on shmorch's own docs/ (the last item in this track's original scope). Remaining scope (appadd/mobos/darkbadge) is the developer's own follow-up, not blocking this track's close.
---

↑ [tracks/20260724-docs-taxonomy-redesign](../20260724-docs-taxonomy-redesign/index.md)
→ `workflows/auto-update.md` (Step 1.9 scoped backfill offer) +
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

### 2026-07-24 — wiring complete, Treeclusion judgment pass done

Closed the three remaining items:

- `core/documentation.md`'s 2026-07-24 changelog row's `Backfill scope` cell now points at
  `tools/backfill-docs-taxonomy.sh` + this track, replacing the old "not yet designed /
  migrate manually" placeholder.
- `workflows/auto-update.md` Step 2.8's "yes" branch now says explicitly: if the `Backfill
  scope` cell names a script, run it for the mechanical part first, then do the judgment
  pass it reports.
- Treeclusion judgment pass: `architecture/decisions.md`, `development/decisions.md`, and
  `development/anti-decisions.md` were all empty stubs (no real entries) — replaced with
  the new `product/decisions/` + `technology/decisions/` template pairs rather than
  "splitting" nothing. `development/notes.md` (also empty) kept standalone at
  `technology/development/notes.md`. `development/guides/index.md` was **not** touched —
  its content (PHP/phpunit, Schwab API TOML, "MoBoS") doesn't belong to Treeclusion at all;
  looks like stale copy-paste from another project's docs, unrelated to this migration.
  Left in place and flagged to the user rather than folding wrong content into the new
  structure. Committed on Treeclusion's `docs/20260724-taxonomy-backfill` branch (two
  commits: the mechanical move, then the judgment pass) — not yet pushed/PR'd there.

`VERSION` bumped to `20260724.05`. This track's core design-and-implementation work is
done; remaining scope is applying the same script + judgment pass to shmorch's own
`docs/state/` (dogfood), then appadd/mobos/darkbadge.

### 2026-07-24 — fixed ordering bug: backfill must run before scaffold diff

PR #70 merged, then user tested `auto-update`/`go` against a real project and hit exactly
the collision this design should have anticipated: `workflows/auto-update.md` ran Step 2
(structural scaffold diff) *before* Step 2.8 (the backfill). On an old-taxonomy project,
Step 2 sees every current-template path as "missing" (since the project's docs/ is still
on the old skeleton) and offers to scaffold them — at the exact destination paths the
backfill script is about to `git mv` real content into. Accepting Step 2's offer first
means the backfill's `git mv` then fails or clobbers on an existing target.

Fix: moved the backfill step earlier, renumbered `Step 2.8` → `Step 1.9`, now running
immediately after Step 1 (version check) and before Step 2. Checked the other 2.x steps
(2.1 reverse scaffold check, 2.3 legacy `shmorch/` rename, 2.4 multi-CLI context chain,
2.5 artifact scan, 2.7 orphaned tool scripts, 2.9 hook sync) — none of them read or write
`docs/` layout, so only the backfill needed to move; nothing else was reordered. `VERSION`
bumped to `20260724.06`.

### 2026-07-30 — shmorch's own dogfood backfill run, track closed

Ran `self-improve` on shmorch itself; its gate script (`check-self-improve-gate.sh`,
hardcoded to `docs/project/timelog.md`) returned `SKIP:no-timelog` because shmorch's own
`docs/` was still the old skeleton — the exact scenario this track exists to fix, just
encountered from the tooling side instead of a scaffold-diff collision. Ran
`tools/backfill-docs-taxonomy.sh` against shmorch's own repo on branch
`docs/20260730-shmorch-dogfood-backfill`:

- 5 mechanical `git mv`s from its mapping (`docs/state/{plan,session,timelog,index}.md`,
  `docs/state/tracks/` → `docs/project/`).
- Found 3 files the script's fixed mapping didn't know about (not flagged as JUDGMENT
  either — a real gap in the script, left as-is since it's a one-off for this repo, not
  worth generalizing for three files): `docs/state/pre-planning.md` (moved to
  `docs/project/`, stale deferred-ideas note, content left untouched), and two
  `docs/architecture/*.md` files not in the script's four-file architecture mapping
  (`feedback-systems.md`, `scheduler-integration.md`, moved to
  `docs/technology/architecture/` matching the existing pattern for that mapping's other
  four files). Also moved `docs/architecture/how-shmorch-works-together.md` (added earlier
  this session, before this migration ran) to the same new location.
- Fixed the now-broken `↑ [Architecture](../index.md)` parent links in the two moved
  architecture docs (a pre-existing dead link even before the move — `docs-audit.sh`
  already flagged it) to `../../README.md`, matching the convention used elsewhere.
- `docs/technology/architecture/scheduler-integration.md` has ~10 literal
  `docs/state/*.md` path references inside cron-job prompt text (operational, not
  historical — the same category as the 2026-07-24 tools/workflows/agents path-reference
  fix) — mechanically rewritten to `docs/project/*.md`.
- `docs/README.md` (this repo's own docs entry point) was stale, still describing the old
  `docs/state/`/`docs/architecture/` layout — updated to the current structure.
- Left untouched, correctly: `core/documentation.md`'s dated Architecture Changelog rows
  (historical record) and `docs/project/{plan,session}.md` / closed track `index.md`
  prose mentioning old paths in past-dated log entries (accurate record of what was true
  then).
- Verified via `docs-audit.sh`: no remaining `DEAD_LINK` findings point at the moved
  files; all findings that remain (a historical track cross-reference, missing
  frontmatter/parent-links on `plan.md`/`session.md`/`timelog.md`/`pre-planning.md`,
  duplicate-content in track files) pre-date this migration and are documentarian-pass
  scope, not backfill scope.

This was the last item in this track's original scope (Treeclusion → shmorch → appadd/
mobos/darkbadge). Closing the track here; appadd/mobos/darkbadge remain the developer's
own follow-up.
