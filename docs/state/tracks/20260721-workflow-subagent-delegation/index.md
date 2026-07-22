---
status: Open
updated: 2026-07-21
summary: Run go/resume/wrap's rote, shmorch-specific steps as subagents returning small JSON, not inline main-thread reads. Feasible; sequence behind cheap index-discipline fix first (see findings.md).
---

↑ [Shmorch Plan](../../plan.md)
→ `workflows/go.md`, `workflows/resume.md`, `workflows/wrap.md`, `workflows/self-improve.md`, `workflows/documentarian.md` (once shipped)

# Track: Workflow subagent delegation — rote, shmorch-specific steps off the main thread

**Status:** Open
**Opened:** 2026-07-21
**Domain:** Skill architecture / context budget

## Why

Surfaced 2026-07-21 while reviewing how much main-thread context Shmorch's own bookkeeping
consumes on every session — `go`/`resume` reading `context.md`/`stack.md`/`session.md`/
`plan.md` in full, `wrap` re-reading much of the same to write updates, `self-improve` and
`documentarian` doing broad scans — all of it competing with the actual project work for
the same context window. `core-breakup` (`tracks/20260601-core-breakup/`) attacks this by
shrinking what's loaded; this track attacks it a different way: **not loading it into the
main thread at all** for the parts of the job that are mechanical and shmorch-specific
rather than project-specific judgment calls.

## Files in this track

| File | Purpose |
|---|---|
| [spec.md](spec.md) | The idea, what it doesn't replace, open questions |
| [findings.md](findings.md) | Simulation against this repo's own state files + feasibility research against existing Shmorch doctrine |

## Related tracks

- `tracks/20260601-core-breakup/` — shrinks what's loaded into the main thread; this
  track removes some of it from the main thread's context entirely. Complementary, not
  competing — do core-breakup's trim regardless, since the subagent itself still pays
  read cost and smaller files are still better.
- `tracks/20260717-state-store-shape/` — subgraph-pull model for state; a structured
  JSON return from a workflow subagent is one plausible shape for "the subgraph," scoped
  per-workflow instead of per-query.
- `tracks/20260525-graph-first-docs/` — this track's own file split (index/spec/findings,
  2026-07-21) is the first live instance of that track's single-responsibility-file
  principle applied to a track folder, not just a `docs/` feature file.

## Backlinks

- [plan.md](../../plan.md) § Architecture
