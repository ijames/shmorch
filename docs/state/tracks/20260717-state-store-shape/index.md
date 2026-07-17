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

## Candidate: richer structured front matter (raised 2026-07-17)

Phase 2 shipped a minimal `status`/`updated`/`summary` front-matter block on
`docs/state/*.md` files, read via `docs/state/index.md`. The open question for this track
is whether to grow that into something closer to a structured front-matter/metadata
catalog convention (the kind used by static-site generators and doc-catalog schemas —
sometimes associated with "Open Knowledge Foundation"-style dataset front matter,
referenced loosely as "Google's OKF" when this was raised) — i.e. richer typed fields
(owner, tags, links, depends-on) that a tool could index across the whole `docs/` tree,
not just `docs/state/`. Trade-off to resolve before adopting: a few plain fields an agent
partial-reads for free vs. a schema that needs a validator/generator to stay honest. Note:
"Google's OKF" wasn't a specific spec either party could point to at time of writing —
treat this as a design inspiration to research, not a citation to implement against
literally.

Do not implement this until a Beads-or-similar backend decision is closer — a metadata
schema on files-that-might-become-graph-nodes should be designed together with the node
shape, not bolted on first.

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
