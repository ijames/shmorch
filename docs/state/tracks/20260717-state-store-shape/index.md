↑ [Shmorch Plan](../../plan.md)
→ `docs/architecture/` (once a backend is chosen and adopted)

# Track: State store shape — graph/wiki backend for tracks & decisions

**Status:** Open
**Opened:** 2026-07-17
**Domain:** State management / context loading

## Why

Split out from `tracks/20260707-entrypoint-consolidation` (its Phase 3), which scoped it
as: "evaluate a graph/wiki backend for state (tracks/decisions) so `go` pulls the
current-focus subgraph, not whole files." Entrypoint-consolidation's own scope is the
dispatcher (`go`/`orient`) and context trim (Phase 1/2); the store-shape question is a
separate, larger architectural decision that deserves its own track rather than sitting
as a deferred bullet blocking that track's closure. Splitting it also lets
entrypoint-consolidation close once Phase 2 lands, instead of staying open indefinitely on
a dependency with no committed timeline.

Do this only after entrypoint-consolidation's Phase 1/2 gains are measured — this track
starts in **Open**, not **Active**, on purpose.

## Prior art / related tracks

- `tracks/20260525-graph-first-docs` — docs as nodes, references as edges, `index.md` as
  surface maps, atomic single-responsibility files, context bundles for JIT loading
- `tracks/20260609-state-file-discipline` — tracks own their state, dev owns root state
- `tracks/20260608-cross-project-knowledge` — concept index with project/commit provenance
- `core/documentation.md` § Front-Matter Previews (landed as part of
  entrypoint-consolidation Phase 2) — the narrow, already-shipped version of "cheap
  partial read before expensive full read," scoped to `docs/state/*.md` only. This track
  is where that idea could grow into the full subgraph-pull model.

## Candidate: richer structured front matter (raised 2026-07-17, OKF comparison added 2026-07-17)

Phase 2 shipped a minimal `status`/`updated`/`summary` front-matter block on
`docs/state/*.md` files, read via `docs/state/index.md`. The open question for this track
is whether to grow that into something closer to a structured front-matter/metadata
catalog convention (the kind used by static-site generators and doc-catalog schemas) — i.e.
richer typed fields (owner, tags, links, depends-on) that a tool could index across the
whole `docs/` tree, not just `docs/state/`. Trade-off to resolve before adopting: a few
plain fields an agent partial-reads for free vs. a schema that needs a validator/generator
to stay honest.

**Concrete citation (previously missing):** [Google's Open Knowledge Format
(OKF)](https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing)
— spec at
[`GoogleCloudPlatform/knowledge-catalog/okf/SPEC.md`](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).
Comparison against Shmorch's current front matter:

| OKF field | Shmorch equivalent | Fit |
|---|---|---|
| `type` (**required** — the only required OKF field) | none | Gap. Nearest analog is directory location (track/plan/session-log/decision), never an explicit field. |
| `description` (recommended) | `summary` | Near-exact — OKF defines it as "a single sentence summarizing the concept," same intent as Shmorch's `summary`. |
| `timestamp` (recommended, ISO 8601 datetime) | `updated` (date only) | Compatible subset — Shmorch is coarser (no time-of-day), same axis. |
| `status` | `status` | No OKF equivalent; rides along as a producer-defined extension key (explicitly legal per OKF §4.1). |
| `title`, `resource`, `tags` | none | Unused by Shmorch; not required by OKF. |

**Structural fit beyond frontmatter fields:** already aligned independently of this
decision — OKF requires `index.md` to carry no frontmatter (§6), matching
`docs/state/index.md` today; OKF conveys relationships via plain body-level markdown
links rather than a frontmatter `links:` field (§5.3), matching Shmorch's `↑`/`→`
body-level nav lines; OKF's reserved `log.md` (dated reverse-chron entries) is the same
shape as `timelog.md` / a track's "Work log" section, just not literally named `log.md`.

**Mergeable — yes.** OKF's conformance bar (§9) is only: every concept file has a
frontmatter block, and `type` is non-empty. Everything else is optional, and consumers
MUST tolerate unknown keys. Shmorch's three existing fields aren't in conflict — the one
gap for actual conformance is adding `type`.

**Extensible — yes, and confirmed compatible with a backlinks section.** OKF explicitly
allows producer-defined extra keys (§4.1) and unconstrained extra body headings; its own
reserved `# Citations` heading is for *outbound* external sources only, not inbound
doc-to-doc backlinks, so a separate `# Backlinks` heading doesn't collide with it. Caveat:
OKF does not itself specify backlink/reverse-index construction — §5.3 leaves graph
traversal entirely to consumer tooling. The backlink-rebuild mechanism below is a
Shmorch-side extension compatible with OKF, not something OKF hands you.

Revised framing (see the rebuild candidate below): not blocked on a Beads-or-similar
backend decision — this field shape, plus the rebuild mechanism, is the trial run for
whether plain markdown + YAML can simulate what a graph backend would give, while staying
human-readable. The backend decision is downstream of that trial, not a prerequisite for it.

## Candidate: deterministic front-matter/nav/backlinks rebuild, run by a subagent (raised 2026-07-17)

Parse the whole `docs/` tree (YAML front matter + markdown body) and deterministically
regenerate three things per file in one pass:

1. **Front matter** — regenerate all fields except `summary`/`description`, which is held
   stable unless the file's underlying content changed since the last regen (avoid
   clobbering a hand-written summary just because a rebuild ran).
2. **Nav block** (`↑`/`→`) — regenerate from actual directory position / declared
   destination, not hand-maintained.
3. **Backlinks section** — walk every markdown link (`[text](path.md#anchor)`) across the
   tree, invert into a reverse index per target file, and emit a generated "Backlinks"
   section listing every doc that links here. This is a solved pattern (Obsidian, Foam,
   Logseq, `mkdocs` backlink plugins all do exactly this) — pure parse-and-invert, no
   judgment required for the graph construction itself. One real caveat: cross-file
   `#anchor` links depend on heading-slugification being consistent across whatever
   renders the docs (GitHub/VS Code/etc.) — CommonMark doesn't define slug rules, so this
   is a renderer convention that needs to hold for the actual toolchain in use, not an
   assumption to bake in blind.

**Design point (the reason this is its own candidate, not folded into the front-matter
one above):** even though the rebuild algorithm is fully deterministic, *execution* should
be a dispatched subagent action, not inline main-thread work — same isolation principle
already applied to `vacuumer`/`documentarian`. Whether an action is deterministic or
judgment-based doesn't determine who runs it; it determines how the run is verified.

Depends on the front-matter/OKF decision above (need the final field shape before the
regenerator can be spec'd) — but not on the Beads-or-similar backend decision. It's the
inverse of what the "do not implement until a backend decision is closer" note above
assumed: this candidate, taken together with the OKF-compatible front matter, **is** the
experiment that informs the backend decision, not a follow-on to it. The premise is to
simulate what a graph backend (Beads or similar) gives you — typed nodes, edges, a
current-focus subgraph pull — using plain YAML-front-matter markdown files plus a
deterministic rebuild pass (front matter + nav + backlinks), and see how far that gets
before the human-readable, `cat`-able, git-diffable form actually breaks down. If it holds
up, a graph/Dolt backend may not be needed at all; if/where it breaks (e.g. backlink
fan-out becomes unreadable, or subgraph-pull needs real queries `grep`/tree-walk can't
give cheaply), that failure point is the concrete argument *for* Beads, and names exactly
what it needs to solve rather than adopting it speculatively.

If concepts do eventually become real graph nodes, "regenerate backlinks" would collapse
into "query the graph" and this rebuild candidate would be superseded, not extended.

## Candidate: Beads (moved from `entrypoint-consolidation` 2026-07-17, originally moved
there from `navigate.md` 2026-07-07)

Beads (Dolt-backed dependency graph) is one candidate backend for this store shape, and
the subject of the standing `plan.md` "Beads integration investigation" item. The
`navigate` workflow's Beads-compatibility mapping lived inline in the live workflow; it
was moved out since it shouldn't ship in `navigate.md` until/unless Beads is actually
adopted.

**If Beads were active (`bd` on PATH), navigate would map as:**
- Step 1 (derive domains): from `bd list --tag domain` or project docs
- Step 2 (map tasks): use tags on beads; `bd ready --json` surfaces unblocked tasks
- Step 4 (drill-down): `bd show <id>` gives task detail; look up functions the same way
- Branch verbs: Build → `bd update <id> --claim`; Break out → `bd dep add` with child IDs; Done → `bd close <id>`
- Hierarchy: Epic (`bd-a3f8`) → Domain; Task (`bd-a3f8.1`) → Item; Sub-task (`bd-a3f8.1.1`) → Phase or function group

A graph store like Beads is exactly this track's direction ("pull the current-focus
subgraph instead of whole files"). Evaluate alongside the `graph-first-docs` /
`state-file-discipline` prior art before adopting, and alongside the front-matter
question above — the two decisions (node storage backend, node metadata shape) should be
made together.

## Work log

### 2026-07-17

- Split out of `entrypoint-consolidation` (that track's Phase 3) so entrypoint-consolidation
  could close on its own Phase 1/2 scope. Carried over the Beads candidate section and the
  prior-art cross-links. Logged the front-matter/OKF idea raised this session as a candidate
  to evaluate once a backend direction is closer, not to implement now.
- Added the concrete OKF citation (blog post + `SPEC.md`) and a field-by-field comparison
  against Shmorch's current `status`/`updated`/`summary` block — conclusion: mergeable
  (OKF's only required field, `type`, is Shmorch's one gap; everything else already fits
  as either a direct match or a legal OKF extension key). Added a second candidate:
  deterministic rebuild of front matter + nav block + a generated backlinks section
  (reverse index of markdown links across the tree), explicitly scoped to run as a
  dispatched subagent action rather than inline main-thread work, regardless of the
  rebuild algorithm being fully deterministic.
- Reframed sequencing: the OKF-shaped front matter + rebuild/backlinks candidate is not
  gated on a prior Beads-or-similar backend decision — it *is* the trial for whether
  plain human-readable markdown + YAML can simulate a graph backend's properties (typed
  nodes, edges, current-focus subgraph pull) before reaching for one. Where it breaks
  becomes the concrete case for Beads, rather than adopting a backend speculatively.
