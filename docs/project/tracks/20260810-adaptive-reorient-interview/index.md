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

## Follow-up — orient/reorient merge + interview-answer history (2026-08-10)

Decided to fold `reorient` into `orient` (one command, no "which one do I run"
split) and add a small history file so repeated interviews can catch
contradictions instead of silently overwriting answers.

- **Command merge:** `commands/reorient.md` and `workflows/reorient.md` are
  removed; their content becomes part of `workflows/orient.md` as new
  tree-gated steps, run on request (`/shmorch orient` becomes directly
  user-invocable, not just an internal step of `go`). `SKILL.md` dispatch
  table and `commands/help.md` updated to point `orient` at a real command
  file instead of `reorient`.
- **Interview-answer history — `docs/project/interview-log.md`:** one small
  append-only file, not a database. Each entry: date, which
  question(s) were (re)answered, the answer, and any discrepancy found.
  Two contradiction checks, run whenever an answer is being (re)recorded:
  1. **Old answer vs new answer** — same question answered differently across
     sessions (e.g. "just you" → "a team").
  2. **Answer vs built system** — cross-check the new answer against
     `docs/{product,technology}/decisions/` (and, where checkable, actual repo
     state) for a standing decision it now contradicts (e.g. answer says "no
     auth needed" but a decisions entry records OAuth was added).
  On a hit, both: surface it to the user inline ("this contradicts what you
  said on <date> / decision <D>— intentional change, or should I leave the
  old answer?") and log it under the entry's `**Discrepancies:**` line so it
  isn't lost if the user brushes past it. No contradiction found → log the
  answer with `**Discrepancies:** none`.
- **Framing:** this is the mechanism that lets Shmorch keep project goals/scope
  intentional rather than accidental — changes get surfaced and chosen, not
  silently drifted into. Related but distinct from
  `docs/project/plan/prompt-goal-alignment-scope-monitor.md` (that one is a
  per-prompt/intake scope-drift check on live work; this is a periodic,
  interview-triggered contradiction check on stated answers). Cross-link the
  two rather than merge them — different trigger, same mission.

## Follow-up — AI/LLM production readiness + default-on posture (2026-08-10)

Two more changes to the same Deep interview, same session:

- **Production Readiness gate flipped from opt-in to default-on** across all six areas
  (existing five + new AI/LLM). The old "want to go through this? yes/skip" top-level gate is
  gone — orient now assumes production readiness matters unless the user explicitly opts out
  ("skip"/"skip all"), consistent with `docs/{product,technology}/decisions/`-driven
  intentionality being the point of this whole track.
- **New AI/LLM area**, based on Google's ML Test Score (data/model/infra/monitoring rubric —
  same production-readiness lineage as SRE PRR) and NIST's AI RMF (Govern/Map/Measure/Manage)
  for the governance question. Depth is explicitly the user's choice (quick pass vs full
  rubric) since AI/LLM involvement varies far more project-to-project than the other five
  areas. Captures an **exposure level** (public / internal / agentic) as its key output.
- **OWASP Top 10 for LLM Applications deliberately excluded from the interview** — per
  developer direction, attack-vector-specific questions don't belong in a user interview; the
  assumption is that no AI/LLM system ships with a known vulnerability regardless of what the
  user says. Instead OWASP LLM Top 10 became a standing build-time guardrail, scaled to the
  exposure level captured above:
  - `workflows/design.md` — new Step 1c: applies exposure-relevant OWASP LLM Top 10
    categories as design constraints before build starts (skips silently if no AI/LLM
    component).
  - `agents/roles/critic.md` — new check #6: adversarial pass now flags an unaddressed
    OWASP LLM Top 10 category (for public/agentic exposure) as a BLOCKER, not a RISK.

## Not in scope

- No new template directory for infrastructure docs — resolved by writing into the existing
  `observability.md` instead.
- No code-level "tree" implementation — the tree is instructions the agent follows
  (gate-then-drill), consistent with every other shmorch workflow being markdown, not code.
- Full enterprise SRE-PRR checklist (capacity planning docs, dependency graphs, runbooks) —
  scoped down to what a solo/small-project developer would plausibly answer.
