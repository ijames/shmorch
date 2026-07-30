---
status: Open
updated: 2026-07-21
summary: Deterministic traversal + graduation check shipped as tools/track-graph-audit.sh, wired into documentarian.md and the Architecture Changelog backfill row.
---

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

### 2026-07-21 — concrete gap found, principle hardened, first instance shipped

`workflows/orient.md` § Working with Tracks has said "Each has index.md, spec.md,
plan.md" since this doctrine was written — but every track folder in this repo (14/14,
checked 2026-07-21) is index.md-only, with everything (why, design, open questions,
research findings) crammed into one growing file. The graph-first principle was written
down but never actually enforced or defaulted-to; tracks accreted content the same way
`docs/state/plan.md` did (see `tracks/20260721-workflow-subagent-delegation/findings.md`
for the plan.md measurement — 665/411-char bullets shrink to 149/144 chars as pure index
entries).

**Principle, hardened:** no file too big — full stop — except a file whose entire job
*is* being an index (clean `status`/`updated`/`summary` front matter, thin body, a
`Backlinks` section) and therefore doesn't accumulate prose by construction. A folder
with only `index.md` and growing is a signal the index absorbed content it should have
delegated.

**First instance:** `tracks/20260721-workflow-subagent-delegation/` split into
`index.md` (surface map: why, file table, related tracks, backlinks) + `spec.md` (the
design) + `findings.md` (simulation + feasibility research) — each under 120 lines, each
carrying the `status`/`updated`/`summary` front matter this doctrine already mandates for
`docs/state/*.md` (§ Front-Matter Previews, `core/documentation.md`) but explicitly
excludes `tracks/` from. That exclusion is the actual bug — tracks are where this matters
most, since they're the files most likely to grow across a long open period.

### 2026-07-21 — deterministic traversal + graduation check shipped

Added `tools/track-graph-audit.sh`: a read-only script (chunk-size cap, front-matter
presence, closed-but-ungraduated candidates) run by `documentarian.md` Step 2 instead of
inline greps, keeping the mechanical scan off the main thread
(`tracks/20260721-workflow-subagent-delegation`). Logged as a `Compat: backfill` row in
`core/documentation.md` § Architecture Changelog so other projects pick it up via
`auto-update.md` Step 2.8. Graduation detection is a proxy (destination doc references
the track dir name back) — false-positive-prone by design, never silently concluding;
Step 3 of `documentarian.md` still does the real read-and-confirm.

**Follow-on backlog, not yet actioned:**
- `workflows/orient.md` § Working with Tracks: either make "index.md, spec.md, plan.md"
  true (documentarian/build.md scaffold it) or correct the line to describe what tracks
  actually default to (index.md + auxiliary files added as content demands them, not a
  fixed three-file template every track must have from open).
- Retrofit is optional, not required — apply the split when a track's index.md is
  visibly carrying multiple concerns (design + research + log), not preemptively to
  every existing track.
