---
loads_when: starting or restructuring any docs/ work — Skeleton Principle, Two-Tier Knowledge System, graduation rules
size: 182 lines
---

# Documentation Doctrine

## The Skeleton Principle

**State has tracks. Docs don't.**

`docs/` is a structural skeleton that fills in as the project matures. It is not a dump of named files — it is a categorical, multidimensional outline of everything that will eventually be documented. As work completes, the skeleton fills in. As docs grow, state shrinks. A complete, mature project has almost no state and a full, navigable docs tree.

**Skeleton structure rules:**

- **Top-level `docs/` subdirectories use generic, cross-project category names** — the same names would make sense in any software project: `product/`, `technology/`, `reference/`, `project/`, `inbox/`. Project-specific names appear only *below* the category level.
- **`docs/<category>/` directories must not be flat file dumps.** Each category should have standard subdirectories for distinct concerns.
- Files are categorically organized within their section
- Subdirectories with dated/versioned content use date/version prefixes inside a named category
- **There is no `docs/tracks/`.** Tracks are project management artifacts — they live in `docs/project/tracks/YYYYMMDD-<name>/` permanently. Knowledge they produce distributes into `docs/<category>/` when the track closes.
- Every section has an `index.md` that links downward; every doc links `↑` to its parent

**The five top-level categories:**

| Category | Role | Key subdirectories |
|---|---|---|
| `product/` | What the system does and why, for the user | `strategy/`, `design/` (+ `concepts/`), `features/`, `decisions/` |
| `technology/` | How it's built | `architecture/` (+ `concepts/`, includes infrastructure as a topic, not a sibling), `development/` (+ `concepts/`, `features/`, `code-styleguides/`, `testing/`), `decisions/` |
| `reference/` | Lookup-only material — no design/development reasoning | `research/` (facts + interpretation of facts, never proposals), `instructions/` (starts flat — `install.md` + `quickstart.md` — grows into Diataxis's `howtos/`/`tutorials/`/`explanations/` only once there's enough content to need the split), flat `<topic>/` folders otherwise |
| `project/` | In-flight, ephemeral — replaces the old `state/` | `sprints/`, `schedule/`, `process/` (paved-road divergences + overrides), `tracks/` (flat; `design-`/`dev-`/`impl-` are filename *prefixes* for readability, not subfolders) |
| `inbox/` | Pre-ingestion holding pen | — |

**Decisions live in exactly two loci — `product/decisions/` and `technology/decisions/`.**
No unified decisions log, no `project/decisions/` (project-level items are process
overrides, which belong in `project/process/`, or are too "soft" to be decision-log
material). `product/`, `technology/`, and their `development/`/`architecture/`
subtrees each get a `concepts/` folder for persistent, living design/dev thinking that
hasn't graduated to a decision yet — built by design/dev tracks, consumed by
implementation tracks, single-responsibility files (~200–400 lines) per the
graph-first-docs discipline (`tracks/20260525-graph-first-docs`).

**Tracks reference destination docs — not the other way around.**

Every track spec has a `→ destination` header naming the specific `docs/` sections it will update when closed. Set at track creation, not at close.

Track closing process:
1. Write knowledge into the `→ destination` doc(s) — integrate it, don't dump it
2. Set `Status: Closed` and `Closed: YYYY-MM-DD` in the track index
3. Update `plan/` (move to Completed)
4. Track directory stays in `docs/project/tracks/` as project management history
5. Run `/shmorch documentarian` to verify knowledge landed correctly

**State diminishes as docs grow.** A project near completion has:
- `docs/project/` — only current in-flight work (plan/, active tracks, spec.md if active)
- `docs/` — nearly complete skeleton
- `docs/project/tracks/` — only open track directories; closed ones have their `→` destinations updated

---

## Two-Tier Knowledge System — State vs Docs

**`docs/project/`** is the in-flight workspace — what is *becoming*.
- Active plans, specs, session notes
- Represents unfinished or intended work; mutable and temporary by design
- **Decisions do not live here** — once made, a decision is permanent and belongs in `docs/product/decisions/` or `docs/technology/decisions/`

**`docs/`** is the authoritative, complete record — what *is*.
- Stable architecture, reference material, product definition
- Grows as a mesh from high-level overview down to implementation detail
- Parity with code and tests: if it's in docs, it's real and working
- A reader of any doc should see exactly what is true now, not a palimpsest

**Graduation rule:** When a spec is fully implemented or a decision is stable — integrate content into the appropriate `docs/` location. `docs/project/` should never accumulate completed work.

| Project file | Graduates to |
|---|---|
| `docs/project/schedule/sprint.md` (closed) | `docs/project/schedule/sprints/YYYYMMDD-<semantic-title>.md` |
| `docs/project/tracks/YYYYMMDD-<name>/` (done) | Knowledge extracted into `docs/<section>/` — track stays in project/ as history |
| `docs/project/spec.md` (implemented) | Cleared to stub; knowledge went to `→ destination` docs |
| `docs/project/stack.md` (stable entries) | `docs/technology/development/tech-stack.md` — stack.md keeps only in-flight/unconfirmed entries |
| `docs/product/decisions/` or `docs/technology/decisions/` entries | Permanent — stays in `decisions/index.md` (or its topic split) |

**Decisions index growth:** when a `decisions/index.md` accumulates many entries (rule of thumb: high entry count, or multiple entries that supersede/correct earlier entries on the same topic), split it into `docs/product/decisions/<topic>.md` or `docs/technology/decisions/<topic>.md` files by topic (e.g. `stack.md`, `process.md`, `data-architecture.md`, `ux-motion.md`, `infra-ops.md`, `product-monetization.md` — topics follow the project's actual decision clusters, not a fixed list). Rewrite `decisions/index.md` itself into a short index linking to each topic file. Each topic file states only the *current* form of each decision, never the history of how it was reached or revised — collapse correction chains into one clean statement. Git log / commit messages are the audit trail for how a decision evolved; the index and its topic files are not. Reference implementation (pre-restructure naming): DarkBadge's `docs/development/decisions/` split (2026-06-19).

**Track file growth:** a track's `index.md` accumulates content by design while it's open — not only a running work log (see "Documents stay clean" — history lives in the timelog and git, but per-round summaries of *what was built and why* legitimately belong in the track while it's open), but also things like a feature inventory, a research dump, or a spec that grow the file just as fast without being a timeline at all. The problem isn't that this content exists, it's that any agent orienting on the track — even just to check current status — pulls the *entire* file into context, including rounds or sections that aren't relevant to what's being decided now. A single `index.md` is only cheap while it's small. Rule of thumb: once a track's `index.md` exceeds roughly 200–300 lines total, split it — same trigger discipline as `decisions.md` above, applied to *this track's own content* instead of *decisions*. The size trigger is on the whole file, not just a "Work log" heading — a track with no work log at all (e.g. a single large feature inventory or spec) still needs splitting once it crosses the threshold:
- **Date/version-based** (the common case — a track accumulating a sequence of dated or version-tagged rounds): move each work-log entry into its own file under `docs/project/tracks/<name>/log/YYYYMMDD-<slug>.md` (or `vN-<slug>.md` when the project tags rounds by version). `index.md` keeps Why/What changes/Open questions and shrinks its Work log section to a one-line-per-entry index linking down to each file.
- **Section-based** (when growth instead comes from distinct sub-concerns living under one track, not a timeline): split by concern into named files under the track directory instead, same index-links-down pattern — e.g. `inventory.md`, `research.md`, `spec.md`, `dev-notes.md`, `test-plan.md`, named for whatever the track's actual sub-concerns are, not a fixed list. `index.md` keeps Why/Status/Open questions and a one-phrase-per-file preview (same Progressive Disclosure shape as any AI-managed index — see below), and becomes the track's top-level knowledge source pointing down at the sibling files for detail. Don't force date-based splitting onto content that isn't actually a sequence.
This doesn't change the graduation model — a track's *knowledge* still only leaves `docs/project/tracks/` for `docs/<category>/` when the track closes (see Graduation rule above). This split keeps an *open, still-growing* track's own footprint from becoming a token liability while it's being read for orientation, nothing more.

**session.md growth:** `docs/project/session.md` is an append-only running log, one dated entry per session — same shape as the two logs above, same trigger discipline. Once it exceeds roughly 200–300 lines (or a handful of dated entries beyond the current one), split every entry *older than* the current `## Latest Session` block into `docs/project/session/YYYYMMDD-<slug>.md`, each with a `↑ [../session.md](../session.md)` back-link header. Replace the archived sections in `session.md` with a `## History` index — one line per entry, newest first, linking down. Keep only the current `## Latest Session` block inline — `workflows/orient.md` only ever reads that block, so the split doesn't change orientation behavior, it just keeps the file small for any other read path.

**External memory (e.g. `~/.claude/projects/...`):** User preferences and feedback belong there. Project state — plans, specs, architecture, decisions — belongs in `docs/project/` or `docs/`, version-controlled with the code.

**Memory placement rule:** Universal Shmorch process guidance belongs in the skill — `shmorch-core.md` or the relevant workflow. Project memory is for project-specific signal only. If a feedback memory would apply equally to any Shmorch project, migrate it to the skill instead.

---

## Progressive Disclosure

**Any information an AI manages but a human consumes must support progressive
disclosure — a summary layer that lets the reader (human or agent) decide whether to go
deeper, before paying the cost of the full read.** This applies beyond `docs/` structure:
any index-shaped artifact an AI builds up over time (a knowledge base, a persona/profile,
a catalog, a changelog) needs the same three layers:

1. **Top-level summary** — a few sentences synthesizing the whole, not a table of contents.
   A reader who stops here should already have a working answer.
2. **One phrase per section** — what's actually in that section right now (not what the
   section is *for* in the abstract), so the reader can skip sections with nothing relevant
   to them instead of opening all of them to find out.
3. **The full content** — only opened once 1 or 2 justified the cost.

An index that only lists filenames or restates the taxonomy ("Section 3: Work Activities")
without saying what's actually *in* section 3 right now fails this — it forces a full read
to answer a question the index should have answered. `docs/project/index.md` and
`docs/product/index.md` (see Front-Matter Previews below) are shmorch's own instance of this
inside the skeleton; `~/.shmorch/personal-profile/profile/index.md`'s "At a glance" +
per-section phrase (added 2026-08-10) is a second, outside `docs/` entirely — same principle,
different artifact shape. When building any new index-shaped file, ask "does layer 1 or 2
already answer the reader's likely question?" before assuming the full file needs opening.

---

## Front-Matter Previews

Every file directly under `docs/project/` (not `tracks/`, not `schedule/`) or
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

`docs/project/index.md` and `docs/product/index.md` are the skeleton indexes: one row per
file in that section, its purpose, and (once front matter is standard) a place to surface
the `summary` line without a full read. `orient.md` Step 0 reads `docs/project/index.md`
first for a fast pulse before pulling whole files. This is the first rung of graph-first
documentation (`tracks/20260525-graph-first-docs`) — cheap partial reads before expensive
full ones — applied to `docs/project/` and `docs/product/` rather than the whole `docs/`
tree.

---

## No Hard Wrapping

Authored markdown is source for a renderer, not a reading surface. Write continuous prose as
continuous lines - no manual line breaks inserted to hit a column width.

A hard wrap is a style decision smuggled into content: a line-length opinion baked in by
whoever last edited the file, in whatever terminal width they happened to have. It can't adapt
to the reader's window, font, or column preference - that's what stylesheets and renderers are
for. It also manufactures bugs: a bullet whose text wraps onto a continuation line, or sits on
the line after a bare `*`, is a common markdown-parser lazy-continuation defect class that only
exists because the source was hard-wrapped in the first place.

- Applies to authoring, not reading. Any tooling that consumes third-party markdown must still
  handle hard-wrapped input correctly - don't assume none exists, just don't write it.
- Applies to continuous prose only. Code blocks, tables, YAML front matter, and list structure
  keep their line breaks.
- Migration is opportunistic: adopt going forward, reflow a file when it's being edited anyway
  for other reasons. No big-bang reflow sweep across a docs tree - the diff would bury real
  history for no behavior change.
- `templates/` needs to move too, or scaffolded projects keep inheriting the old convention by
  imitation.
- Semantic line breaks (one sentence per line) were considered and rejected: they still insert
  linefeeds into continuous prose, which is exactly what this rule is against.

---

## Architecture Changelog

Moved to `$SHMORCH_HOME/core/changelog.md` — a migration ledger `auto-update.md` reads
mechanically, not doctrine. Log new `Compat: backfill` rows there, not here.
