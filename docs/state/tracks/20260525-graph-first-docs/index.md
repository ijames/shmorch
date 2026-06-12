↑ [Shmorch Plan](../../plan.md)
→ `core/documentation.md` + `workflows/documentarian.md` + `workflows/init.md`

# Track: Graph-first documentation

**Status:** Open
**Opened:** 2026-05-25
**Domain:** Documentation architecture

## Why

Docs are currently organized as a flat tree. The graph-first model treats docs as nodes and references as edges: `index.md` files become surface maps (which features appear where, for which consumers) rather than flat listings. Feature files are single-responsibility, small (~200–400 lines max), and referenced rather than copied. Consumer-aware traversal means different readers follow different subgraphs.

Connects directly to JIT context loading — a well-structured graph means Shmorch loads only the subgraph relevant to the current task rather than broad files speculatively.

Source: DarkBadge `docs/development/notes.md` §Graph-First Documentation Architecture.

## What changes

1. Documentarian gains size-limit checks (flags files over ~400 lines as single-responsibility violations)
2. `init` scaffolds `index.md` as a surface map, not a flat listing
3. A "context bundle" concept documented — named traversal paths for common task types (e.g. "I'm starting a build task on X" → load this subgraph)

## Work log

### 2026-05-25
Design concept surfaced during DarkBadge session.
