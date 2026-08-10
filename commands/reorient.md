# Command: reorient

Adaptive, tree-structured interview: Project Focus & Shape, and Production
Readiness (SRE PRR-based). Each category is gated by one high-level question
before any sub-questions are asked — say "skip" to bypass a whole category or
any single question in it. Safe to re-run any time; updates existing answers
instead of requiring a blank `context.md`.

Distinct from `orient`'s fixed 6-question first-run Context Setup: that one
stays minimal by design (fast first contact). `reorient` is the deeper,
recurring pass for when a project's shape or production posture has changed.

## When to run
- Periodically, as a project's scope or production posture changes
- When orient's fixed questions feel stale or too shallow
- The first time a project moves toward real users and production-readiness
  questions (monitoring, security, backups) start to matter

## Dispatches to
`workflows/reorient.md`

## Variants
- `/shmorch reorient` — walks both categories
- `/shmorch reorient focus` — Project Focus & Shape only
- `/shmorch reorient readiness` — Production Readiness only
