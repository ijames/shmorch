# Documentation Doctrine

## The Skeleton Principle

**State has tracks. Docs don't.**

`docs/` is a structural skeleton that fills in as the project matures. It is not a dump of named files — it is a categorical, multidimensional outline of everything that will eventually be documented. As work completes, the skeleton fills in. As docs grow, state shrinks. A complete, mature project has almost no state and a full, navigable docs tree.

**Skeleton structure rules:**

- **Top-level `docs/` subdirectories use generic, cross-project category names** — the same names would make sense in any software project: `architecture/`, `development/`, `product/`, `reference/`. Project-specific names appear only *below* the category level.
- **`docs/<category>/` directories must not be flat file dumps.** Each category should have standard subdirectories for distinct concerns.
- Files are categorically organized within their section
- Subdirectories with dated/versioned content use date/version prefixes inside a named category
- **There is no `docs/tracks/`.** Tracks are project management artifacts — they live in `docs/state/tracks/YYYYMMDD-<name>/` permanently. Knowledge they produce distributes into `docs/<category>/` when the track closes.
- Every section has an `index.md` that links downward; every doc links `↑` to its parent

**Tracks reference destination docs — not the other way around.**

Every track spec has a `→ destination` header naming the specific `docs/` sections it will update when closed. Set at track creation, not at close.

Track closing process:
1. Write knowledge into the `→ destination` doc(s) — integrate it, don't dump it
2. Set `Status: Closed` and `Closed: YYYY-MM-DD` in the track index
3. Update `plan.md` (move to Completed)
4. Track directory stays in `docs/state/tracks/` as project management history
5. Run `/shmorch documentarian` to verify knowledge landed correctly

**State diminishes as docs grow.** A project near completion has:
- `docs/state/` — only current in-flight work (plan.md, active tracks, spec.md if active)
- `docs/` — nearly complete skeleton
- `docs/state/tracks/` — only open track directories; closed ones have their `→` destinations updated

---

## Two-Tier Knowledge System — State vs Docs

**`docs/state/`** is the in-flight workspace — what is *becoming*.
- Active plans, specs, session notes
- Represents unfinished or intended work; mutable and temporary by design
- **Decisions do not live here** — once made, a decision is permanent and belongs in `docs/development/decisions.md`

**`docs/`** is the authoritative, complete record — what *is*.
- Stable architecture, reference material, product definition
- Grows as a mesh from high-level overview down to implementation detail
- Parity with code and tests: if it's in docs, it's real and working
- A reader of any doc should see exactly what is true now, not a palimpsest

**Graduation rule:** When a spec is fully implemented or a decision is stable — integrate content into the appropriate `docs/` location. `docs/state/` should never accumulate completed work.

| State file | Graduates to |
|---|---|
| `docs/state/schedule/sprint.md` (closed) | `docs/state/schedule/sprints/YYYYMMDD-<semantic-title>.md` |
| `docs/state/tracks/YYYYMMDD-<name>/` (done) | Knowledge extracted into `docs/<section>/` — track stays in state/ as history |
| `docs/state/spec.md` (implemented) | Cleared to stub; knowledge went to `→ destination` docs |
| `docs/development/decisions.md` entries | Permanent — stays in `decisions.md` |

**Decisions.md growth:** when `decisions.md` accumulates many entries (rule of thumb: high entry count, or multiple entries that supersede/correct earlier entries on the same topic), split it into `docs/development/decisions/<topic>.md` files by topic (e.g. `stack.md`, `process.md`, `data-architecture.md`, `ux-motion.md`, `infra-ops.md`, `product-monetization.md` — topics follow the project's actual decision clusters, not a fixed list). Rewrite `decisions.md` itself into a short index linking to each topic file — keep it at that same path so existing inbound links from tracks/architecture docs don't break. Each topic file states only the *current* form of each decision, never the history of how it was reached or revised — collapse correction chains into one clean statement. Git log / commit messages are the audit trail for how a decision evolved; `decisions.md` and its topic files are not. Reference implementation: DarkBadge's `docs/development/decisions/` split (2026-06-19).

**External memory (e.g. `~/.claude/projects/...`):** User preferences and feedback belong there. Project state — plans, specs, architecture, decisions — belongs in `docs/state/` or `docs/`, version-controlled with the code.

**Memory placement rule:** Universal Shmorch process guidance belongs in the skill — `shmorch-core.md` or the relevant workflow. Project memory is for project-specific signal only. If a feedback memory would apply equally to any Shmorch project, migrate it to the skill instead.

---

## Front-Matter Previews

Every file directly under `docs/state/` (not `tracks/`, not `schedule/`) or
`docs/product/` (not `index.md` — the index is pure navigation, nothing to preview)
opens with a three-line YAML block so an agent — or the section's `index.md` — can
preview the file's gist by reading the first few lines, without opening the whole thing:

```yaml
---
status: <Open | Active | Blocked | Done>
updated: YYYY-MM-DD
summary: <one line — what this file currently says>
---
```

`status`/`updated`/`summary` only — this is a preview, not a metadata system. Update the
block whenever the file's content changes materially (same discipline as "Documents stay
clean" — the front matter is current reality, not a log of past states).

`docs/state/index.md` and `docs/product/index.md` are the skeleton indexes: one row per
file in that section, its purpose, and (once front matter is standard) a place to surface
the `summary` line without a full read. `orient.md` Step 0 reads `docs/state/index.md`
first for a fast pulse before pulling whole files. This is the first rung of graph-first
documentation (`tracks/20260525-graph-first-docs`) — cheap partial reads before expensive
full ones — applied to `docs/state/` and `docs/product/` rather than the whole `docs/`
tree.

---

## Architecture Changelog

This doctrine is not mirrored into projects (unlike `templates/.shmorch/`, which
`auto-update.md` diffs and syncs file-by-file) — every project reads this file live from
`$SHMORCH_HOME/core/documentation.md`, so the *rules* are always current automatically.
What can't update itself is a project's *existing docs content* written under an older
version of these rules. This changelog is how `auto-update.md` knows when that content
needs a backfill pass, and how big a pass.

**Only log an entry here when a rule changes what existing docs *should already contain*
or *where they should already live* — not for wording or clarification edits.** Every entry
gets a `Compat` tag:

- `Compat: additive` — new option, doesn't invalidate anything already written. No backfill offered.
- `Compat: backfill` — existing docs written before this date no longer conform. `auto-update.md` offers a scoped backfill for this entry specifically.

No separate semver scheme — the date already in `VERSION` (`YYYYMMDD.NN`) is the only
comparison axis `auto-update.md` needs: an entry's date > the project's last-synced date
means the project predates that rule.

| Date | Rule | Compat | Backfill scope |
|---|---|---|---|
| 2026-07-17 | `docs/state/*.md` (not `tracks/`, not `schedule/`) require the `status`/`updated`/`summary` front-matter block (see § Front-Matter Previews) | `backfill` | Add the block to any `docs/state/*.md` file that lacks one. Derive `status`/`summary` from the file's current content — don't guess, read it. |
| 2026-07-22 | `docs/product/*.md` (not `index.md`) require the same `status`/`updated`/`summary` front-matter block as `docs/state/*.md` (see § Front-Matter Previews) | `backfill` | Add the block to any `docs/product/*.md` file (excluding `index.md`) that lacks one. Derive `status`/`summary` from the file's current content — don't guess, read it. |

Add new rows here, newest first, whenever a change in this doctrine falls into the
`backfill` category.
