↑ [Shmorch Plan](../../plan.md)
→ new `workflows/solidify.md` + `commands/solidify.md` + `core/documentation.md` (execution-model section)

# Track: Docs solidification framework — deterministic, resumable, cross-project

**Status:** Open
**Opened:** 2026-07-17
**Domain:** Documentation architecture

## Why

Three tracks already describe *what* a solidified docs tree should look like
(`20260525-graph-first-docs` — target shape; `20260717-state-store-shape` — target
backend/format) and one already audits *whether current docs match code*
(`workflows/documentarian.md` — parity triage). None of them specify the *procedure* a
session runs to take an arbitrary project's messy or partial `docs/` and actually turn it
into skeleton-compliant shape — deterministically, the same end-state regardless of which
session did the work or how many times it was interrupted.

Today's request: this needs to work "across multiple sessions and deterministically" and
"across any project" — not just shmorch's own repo. Right now, restructuring docs is
improvised per-session judgment. That means: (a) a session that gets interrupted mid-pass
has no reliable way to resume exactly where it left off without re-reading everything, and
(b) two different sessions asked to solidify the same messy tree could produce different
results, because there's no fixed phase order or fixed classification rule.

## What changes

1. **New workflow `workflows/solidify.md` + command `commands/solidify.md`** — a fixed
   phase sequence (Inventory → Classify → Restructure → Verify → Checkpoint) that any
   session runs in the same order, on any project, producing the same target shape.
2. **A persisted checkpoint artifact** — one file per phase's output, written as the phase
   completes (not batched at the end), so a session that stops after Classify can resume
   directly at Restructure without re-deriving the classification. Lives in the track
   directory per `20260609-state-file-discipline` (track owns its state while open).
3. **Reuses `documentarian.md`'s triage protocol** (`DOC_STALE` / `CODE_DIVERGED` /
   `TEST_GAP` / `UNDECIDED`) as the Classify phase's decision rule instead of inventing a
   second classification scheme — solidify and documentarian should share one triage
   vocabulary.
4. **Target shape = `core/documentation.md`'s Skeleton Principle** (generic category
   names, `index.md` as surface map, tracks-not-docs) plus `20260525-graph-first-docs`'s
   size-limit and context-bundle refinements, once that track lands them. Solidify doesn't
   redesign the shape — it's the executor that converges any project's tree onto it.
5. **Project-agnostic** — no shmorch-specific assumptions; runs against
   `$SHMORCH_HOME`-resolved paths so it works the same on a project scaffolded by `init`
   last week or one with three years of undisciplined docs.

## Non-goals / relationship to sibling tracks

- Does **not** decide the storage backend (front-matter vs. graph/wiki) — that's
  `20260717-state-store-shape`. Solidify targets whatever shape that track lands on.
- Does **not** design the target graph shape — that's `20260525-graph-first-docs`.
  Solidify consumes its output (size limits, context bundles) once defined; until then it
  targets the shape already documented in `core/documentation.md`.
- Does **not** replace `documentarian` — documentarian audits parity between existing docs
  and code/tests. Solidify is the one-time (or occasional) *structural* migration a project
  runs when its docs tree itself is out of shape, not just out of sync.

## Deterministic execution model (draft)

- **Phase order is fixed and idempotent.** Re-running a completed phase against unchanged
  input produces the same output — no phase depends on conversational context that isn't
  also written to the checkpoint.
- **Phase 1 — Inventory:** walk the project's `docs/` + `docs/state/`, produce a flat
  manifest (path, size, front-matter if present, last-git-touch). Write to checkpoint.
- **Phase 2 — Classify:** for every manifest entry, decide its target: stays in place /
  moves to `docs/<category>/` / graduates from `docs/state/` / merges with a sibling /
  flagged `UNDECIDED` for the developer. Uses documentarian's triage vocabulary. Write to
  checkpoint — this is the expensive reasoning step, must never be redone silently.
- **Phase 3 — Restructure:** apply only the moves/merges from the checkpoint's Classify
  output. No new judgment calls at this phase — if Classify didn't decide it, Restructure
  doesn't act on it.
- **Phase 4 — Verify:** run documentarian's parity check against the new structure; confirm
  no orphaned links, no broken `↑`/`→` references.
- **Phase 5 — Checkpoint/close:** mark the run complete in the checkpoint file; if resuming
  a prior run, phases already checkpointed are skipped entirely, not re-verified.

Open question for Work log: does the checkpoint artifact live in the track directory only
(this track's own state), or does solidify need a per-project persistent checkpoint outside
any track (since a project's docs tree may need re-solidifying long after this track
closes)? Resolve before Phase 1 implementation.

## Work log

### 2026-07-17
Track opened at user request: shmorch needs a deterministic, multi-session-safe,
project-agnostic way to restructure docs/knowledge structure, built on what graph-first-docs,
state-store-shape, state-file-discipline, and documentarian already established rather than
starting from scratch. Scoped as the missing *executor* connecting those design/audit tracks.
