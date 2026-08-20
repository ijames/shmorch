---
loads_when: never loaded as doctrine — read mechanically by workflows/auto-update.md Step 1.9
size: 30 lines
---

# Architecture Changelog

Not mirrored into projects (unlike `templates/.shmorch/`, which `auto-update.md` diffs and
syncs file-by-file) — every project reads this file live from `$SHMORCH_HOME/core/changelog.md`
during sync. `core/documentation.md`'s doctrine is always current automatically; what can't
update itself is a project's *existing docs content* written under an older version of that
doctrine. This table is how `auto-update.md` knows when that content needs a backfill pass,
and how big a pass. It is a migration ledger, not doctrine — see `core/documentation.md` for
the actual rules being referenced below.

**Only log an entry here when a rule changes what existing docs *should already contain*
or *where they should already live* — not for wording or clarification edits.** Every entry
gets a `Compat` tag:

- `Compat: additive` — new option, doesn't invalidate anything already written. No backfill offered.
- `Compat: backfill` — existing docs written before this date no longer conform. `auto-update.md` offers a scoped backfill for this entry specifically. Per `core/operations.md`'s VERSION bump rule: MAJOR if it's a structural/scaffold change existing projects are now non-conforming with, MINOR if it's an optional pattern/capability addition that doesn't restructure anything already in place.

`VERSION` is semantic (`MAJOR.MINOR.PATCH`) since `1.0.0` (2026-08-04); before that it was
`YYYYMMDD.NN` — see `docs/project/tracks/20260804-semver-versioning/`. Rows below `1.0.0`
predate semver entirely and carry only the legacy `Date` they were added on; `auto-update.md`
compares those against a project's pre-update `VERSION` date whenever that project itself
predates `1.0.0`. Rows at `1.0.0` or later carry both the calendar `Date` they landed on
(for human reference) and the `Version` they shipped in; `auto-update.md` compares `Version`
numerically (MAJOR, then MINOR, then PATCH) against a project's `VERSION` once that project
is itself on semver.

| Date | Version | Rule | Compat | Backfill scope |
|---|---|---|---|---|
| 2026-08-20 | 2.1.4 | Authored markdown must not be hard-wrapped - continuous prose stays continuous, no manual linefeeds inserted to hit a column width - see `core/documentation.md` § No Hard Wrapping | `additive` | No backfill offered - existing hard-wrapped files remain valid; reflow opportunistically when a file is next edited, and reauthor `templates/` unwrapped over time |
| 2026-08-18 | 2.1.0 | `docs/project/session.md` files exceeding ~200–300 lines (or a handful of dated entries beyond the current one) must split per `core/documentation.md` § session.md growth — older entries move to `docs/project/session/YYYYMMDD-<slug>.md`, `session.md` keeps only `## Latest Session` plus a `## History` index | `backfill` | For each project's `session.md` over the threshold, move every entry older than the current `## Latest Session` block into its own `docs/project/session/` file, replace the archived sections with a `## History` index linking down. Do not touch the current `## Latest Session` block. |
| 2026-08-10 | — | Any index-shaped artifact an AI manages for human consumption (not just `docs/project/index.md`/`docs/product/index.md`) should carry a top-level summary plus a one-phrase-per-section preview — see `core/documentation.md` § Progressive Disclosure | `additive` | No backfill offered — existing indexes remain valid; apply going forward and opportunistically when an index is next touched |
| 2026-07-24 | — | Top-level `docs/` taxonomy replaced: `architecture/`, `development/`, `product/`, `reference/`, `state/`, `to_review/` → `product/`, `technology/` (architecture + development merged under it), `reference/` (Diataxis-scoped `instructions/` + `research/`), `project/` (was `state/`), `inbox/` (was `to_review/`). Decisions split into `product/decisions/` + `technology/decisions/` only (no unified log, no `project/decisions/`). See `tracks/20260724-docs-taxonomy-redesign` | `backfill` | Run `tools/backfill-docs-taxonomy.sh` for the mechanical `git mv`s, then a judgment pass on the files it reports (decisions/anti-decisions splits, dev notes, deployment content, and any other real-content file with no 1:1 new home) per `tracks/20260724-dev-docs-taxonomy-backfill` |
| 2026-07-23 | — | Track `index.md` files whose Work log section exceeds ~200–300 lines (or spans many dated/versioned rounds) must split per `core/documentation.md` § Track file growth — date/version-based into `docs/project/tracks/<name>/log/YYYYMMDD-<slug>.md`, or section-based when growth isn't a timeline | `backfill` | For each open track over the threshold, move each work-log entry into its own `log/` file, replace the Work log section in `index.md` with a one-line-per-entry index linking down. Do not touch Why/What changes/Open questions. |
| 2026-07-22 | — | `docs/product/*.md` (not `index.md`) require the same `status`/`updated`/`summary` front-matter block as `docs/state/*.md` (see `core/documentation.md` § Front-Matter Previews) | `backfill` | Add the block to any `docs/product/*.md` file (excluding `index.md`) that lacks one. Derive `status`/`summary` from the file's current content — don't guess, read it. |
| 2026-07-21 | — | `docs/state/tracks/**/*.md` require the same front-matter block as `docs/state/*.md`, and closed tracks (`Status: Closed`) whose `→ destination` doc doesn't reference them back are graduation candidates (see `tracks/20260525-graph-first-docs`) | `backfill` | Run `bash $SHMORCH_HOME/tools/track-graph-audit.sh`. Add front-matter to every `MISSING_FRONTMATTER` file (derive from content, don't guess). For every `CLOSED_UNGRADUATED` line, read the track and its destination doc, confirm whether knowledge actually landed, and integrate what's missing — the script only finds candidates, it doesn't conclude. |
| 2026-07-17 | — | `docs/state/*.md` (not `tracks/`, not `schedule/`) require the `status`/`updated`/`summary` front-matter block (see `core/documentation.md` § Front-Matter Previews) | `backfill` | Add the block to any `docs/state/*.md` file that lacks one. Derive `status`/`summary` from the file's current content — don't guess, read it. |

Add new rows here, newest first, whenever a change in `core/documentation.md` falls into the
`backfill` category.
