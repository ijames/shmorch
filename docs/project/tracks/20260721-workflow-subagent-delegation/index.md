---
status: Open
updated: 2026-08-10
summary: Umbrella for three context-budget branches — A frontmatter gating, B subagent delegation (original scope), C core/workflow doc JIT breakup (absorbs tracks/20260601-core-breakup/). See comparison.md for recommendation and sequencing.
---

↑ [Shmorch Plan](../../plan/index.md)
→ `workflows/go.md`, `workflows/resume.md`, `workflows/wrap.md`, `workflows/self-improve.md`, `workflows/documentarian.md`, `workflows/*.md`, `core/*.md` (once shipped)

# Track: Workflow subagent delegation — rote, shmorch-specific steps off the main thread

**Status:** Open
**Opened:** 2026-07-21
**Domain:** Skill architecture / context budget

## Why

Surfaced 2026-07-21 while reviewing how much main-thread context Shmorch's own bookkeeping
consumes on every session — `go`/`resume` reading `context.md`/`stack.md`/`session.md`/
`plan.md` in full, `wrap` re-reading much of the same to write updates, `self-improve` and
`documentarian` doing broad scans — all of it competing with the actual project work for
the same context window.

Re-scoped 2026-08-10 after a user report that `go` and `wrap` both blow up available
context in practice, not just in theory: this is now the umbrella for **three** levers on
the same problem, spec'd as separate branches so they can be built and measured
independently —

- **[Approach A](approach-a-frontmatter-gating.md)** — read only a file's frontmatter to
  decide whether to open its body at all.
- **[Approach B](approach-b-subagent-delegation.md)** — this track's original scope: run
  rote steps as a subagent, return small JSON, main thread never opens the source files.
- **[Approach C](approach-c-core-doc-breakup.md)** — shrink individual file bodies via JIT
  sub-files; absorbs `tracks/20260601-core-breakup/` (that track's original scope,
  `shmorch-core.md` specifically, turns out to be mostly already done — see C for the
  current, broader remaining surface: `workflows/*.md`).

See [comparison.md](comparison.md) for the scorecard and recommended sequencing (A first).

## Files in this track

| File | Purpose |
|---|---|
| [comparison.md](comparison.md) | **Start here** — scorecard across A/B/C, recommendation, sequencing |
| [approach-a-frontmatter-gating.md](approach-a-frontmatter-gating.md) | Branch A — frontmatter-gated loading |
| [approach-b-subagent-delegation.md](approach-b-subagent-delegation.md) | Branch B — subagent delegation (pointers into spec.md/findings.md) |
| [approach-c-core-doc-breakup.md](approach-c-core-doc-breakup.md) | Branch C — core/workflow doc JIT breakup |
| [spec.md](spec.md) | Branch B's original detailed design |
| [findings.md](findings.md) | Branch B's simulation + feasibility research — also the source of A's "69% free" measurement |

## Related tracks

- `tracks/20260601-core-breakup/` — **absorbed as Approach C** (2026-08-10). Its original
  scope (`shmorch-core.md` specifically) is largely done; remaining scope moved here and
  broadened to `workflows/*.md`. That track's index.md now points back to this one.
- `tracks/20260717-state-store-shape/` — subgraph-pull model for state; a structured
  JSON return from a workflow subagent is one plausible shape for "the subgraph," scoped
  per-workflow instead of per-query.
- `tracks/20260525-graph-first-docs/` — this track's own file split (index/spec/findings,
  2026-07-21) is the first live instance of that track's single-responsibility-file
  principle applied to a track folder, not just a `docs/` feature file.

## Backlinks

- [plan.md](../../plan/index.md) § Architecture
