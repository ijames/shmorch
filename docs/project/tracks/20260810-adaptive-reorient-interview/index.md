---
status: Active
updated: 2026-08-10
summary: New `/shmorch reorient` command — a re-runnable, tree-gated interview covering project focus/shape and SRE-PRR-based production readiness, distinct from orient's fixed one-time Context Setup. Fixed a real doctrine contradiction found along the way (docs/technology/infrastructure listed as canonical scaffold dir but never templated, and conflicting with architecture/index.md's "infra is a topic, not a sibling dir" rule).
---

↑ [core/operations.md](../../../../core/operations.md)
→ [workflows/orient.md](../../../../workflows/orient.md), [workflows/reorient.md](../../../../workflows/reorient.md), [core/git-discipline.md](../../../../core/git-discipline.md)

# Track: Adaptive reorient interview

**Status:** Active
**Started:** 2026-08-10
**Domain:** shmorch skill — new command/workflow, orient.md pointer, EXPECTED_DOCS fix

## Why

`orient.md`'s Context Setup asks 6 fixed questions once, on first init, and never again.
There was no question anywhere in the flow about production-readiness concerns (monitoring,
alerting, security, backups, cost, on-call) or about revisiting project focus/shape as a
project evolves. The user asked for this to be modeled on an established framework (Google's
SRE Production Readiness Review) rather than an invented checklist, and to be tree-structured
so a small/solo project isn't forced through enterprise-scale questions it doesn't need —
each category and sub-question is gated behind an explicit opt-in, skippable at any level.

## What changed

- **`commands/reorient.md`** — new command, dispatches to `workflows/reorient.md`.
  Variants: `/shmorch reorient` (both categories), `/shmorch reorient focus`,
  `/shmorch reorient readiness`.
- **`workflows/reorient.md`** — new workflow. Two gated categories:
  - **Project Focus & Shape** — success definition, audience, anti-decisions, hard
    constraints. Written to `docs/project/context.md`.
  - **Production Readiness** (SRE-PRR-based, scoped to solo/small-project scale) —
    monitoring/alerting, security, backup/DR, cost/capacity, on-call/escalation. Each area
    has its own gate question before any follow-up. Written to
    `docs/technology/architecture/observability.md` (existing file, already scoped for this:
    "fill before going to prod" — not a new directory).
  - Re-runnable: tracks "Last reoriented: DATE" in `context.md`, updates existing answers in
    place instead of requiring a blank slate — this is what makes it distinct from orient's
    one-time interview.
- **`workflows/orient.md`** — added a pointer after the fixed Context Setup questions,
  telling the user `/shmorch reorient` exists for deeper/recurring questions. The original 6
  questions are unchanged — reorient is additive, not a replacement.
- **`SKILL.md`** — added `reorient` to the dispatch table and the trigger-word list.
- **`commands/help.md`** — added a reorient line under SESSION.
- **Bug found and fixed while wiring the write target:** `docs/technology/infrastructure`
  was added to `EXPECTED_DOCS` in `self-improve.md` and `auto-update.md` (PR #99,
  2026-08-09) as a canonical scaffold directory, but no `templates/docs/technology/infrastructure/`
  ever existed — `auto-update`'s "copy from skill templates" step would have silently done
  nothing for it. It also directly contradicts `docs/technology/architecture/index.md`'s
  explicit statement that infrastructure is a topic living inside `architecture/`
  (`observability.md`), not a separate sibling directory. Removed the entry from both
  `EXPECTED_DOCS` lists and from `auto-update.md`'s Step 2 directory-check list.

## Not in scope

- No new template directory for infrastructure docs — resolved by writing into the existing
  `observability.md` instead.
- No code-level "tree" implementation — the tree is instructions the agent follows
  (gate-then-drill), consistent with every other shmorch workflow being markdown, not code.
- Full enterprise SRE-PRR checklist (capacity planning docs, dependency graphs, runbooks) —
  scoped down to what a solo/small-project developer would plausibly answer.
