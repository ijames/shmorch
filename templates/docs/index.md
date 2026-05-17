# AppAddict — Documentation Index

> Start here. Every document in the project is reachable from this page.
> Permanent docs live under `docs/`. In-flight work lives under `docs/state/`.

---

## What This Project Is

AppAddict scores apps and games on addictive design patterns, displays the results visually, and lets users ask questions about what they're seeing. The scoring rubric is grounded in academic research on gambling mechanics that migrated into everyday software.

**Hero flow:** User types in any app → evidence is collected → AI scores it → radar chart appears.

---

## Permanent Documentation

### Product
Understanding what <> is and how it thinks.

- [Cognitive Architecture](product/cognitive-architecture.md) — The 5-engine AI pipeline: Evidence → Summarization → Scoring → Verification → Explanation
- [Scoring Rubric v1](reference/scoring-rubric-v1.md) — Hybrid framework: Schüll (Solitude, Bottomlessness, Speed, Teasing) + Fogg/Eyal (Social Pressure). **Locked 2026-04-29.**

### Architecture
How the system is structured at a conceptual level. Tech-agnostic.

- [System Components](architecture/system-components.md) — 

### Reference
Source material and foundational documents.

- 

### Development Record
Permanent decisions and paths not taken. Never deleted.

- [Decisions](development/decisions.md) — Every product, architecture, process, and tooling decision
- [Anti-Decisions](development/anti-decisions.md) — Paths explicitly considered and rejected
- [Notes](development/notes.md) — Captured concepts, design philosophy, and feature ideas with enough depth to preserve in full

---

## In-Flight State

> These files represent work in progress. Contents change daily.
> When a track closes or a spec is fully implemented, content graduates to permanent docs above.

### Current Focus
- [Plan](state/plan.md) — Current task + backlog
- [Spec](state/spec.md) — Active MVP feature specification ⚠️ _draft — not locked_
- [Sprint](state/sprint.md) — 14-day calendar and daily objectives
- [Session](state/session.md) — Cross-session continuity notes
- [Stack](state/stack.md) — Tech stack inventory ⚠️ _TBD until explicitly locked_
- [Context](state/context.md) — Project identity and preferences

### Active Tracks
- [AppAddict App](state/tracks/appaddict-app/index.md) — Main product build
  - [Acceptance Scenarios (Gherkin)](state/tracks/appaddict-app/features.gherkin) — 5-dimension rubric locked, scenarios active
- [Portfolio Evidence](state/tracks/portfolio-evidence/index.md)
- [Shmorch: BDD Enforcement](state/tracks/shmorch-bdd/index.md)
- [Shmorch: Deploy Role](state/tracks/shmorch-deploy-role/index.md)

### Records
- [Timelog](state/timelog.md) — Session and task timing
- [Closed Sprints](state/schedule/README.md)

---

## Document Health

| Symbol | Meaning |
|---|---|
| _(no marker)_ | Stable — reflects current reality |
| ⚠️ _draft_ | Written but not reviewed/confirmed |
| ⚠️ _TBD_ | Placeholder — decision pending |
| ⚠️ _blocked_ | Cannot be finalized until a dependency resolves |

---

↓ children: all documents listed above
