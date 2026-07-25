---
status: Closed
updated: 2026-07-24
summary: Docs taxonomy redesign closed and implemented — templates/docs/** restructured to inbox/project/product/technology/reference; core/documentation.md, shmorch-core.md, and track-template.md updated. Backfill for already-provisioned projects split to tracks/20260724-dev-docs-taxonomy-backfill.
---

↑ [core/documentation.md](../../../../core/documentation.md)
→ `core/documentation.md` + `shmorch-core.md` + `templates/docs/**` +
`templates/.shmorch/docs/track-template.md` — all updated. Backfill mechanics for
already-provisioned projects split to
[tracks/20260724-dev-docs-taxonomy-backfill](../20260724-dev-docs-taxonomy-backfill/index.md).

# Track: Docs taxonomy redesign — SDLC-first top level, Diataxis within reference

**Status:** Closed
**Opened:** 2026-07-24
**Closed:** 2026-07-24
**Domain:** Documentation architecture

## Why

Round 2/3 of an ongoing rehash (prior rounds not previously tracked — this is the first
written record). Triggered by a user question about whether Diataxis (diataxis.fr) should
reshape Shmorch's docs skeleton. Diagnosis across two live projects
(`AppAdd/appadd/docs/`, `MoBoS/mobos/docs/`, audited via subagents 2026-07-24) found:

- The five-category core (`product/`, `architecture/`, `development/`, `reference/`,
  `state/`) is consistent across all three shmorch-managed trees (shmorch itself, appadd,
  mobos) — the skeleton principle is working structurally.
- `architecture/` and `reference/` are **not** cleanly split by content type in either
  project. Per-file classification found only 2 files total across both projects that read
  as unambiguous pure-lookup content (`scoring-rubric.md`, the raw Schwab API dump).
  Everything else in both folders — including files that literally live in the "reference"
  or "architecture" folder — is narrative: rationale, history, glossary, how-to, market
  research. Diagnosis: neither folder enforces a content-type discipline, so each
  accumulates one of everything, because they're organized by SDLC-phase/subject, and
  Diataxis organizes by reader-intent — two orthogonal axes competing for one folder tree.
- Real doctrine bugs found as a side effect: `mobos/development/index.md` states its own
  graduation rule ("decisions live in development before they graduate to architecture")
  but mobos's actual practice puts `decisions.md`/`anti-decisions.md` directly in
  `architecture/` — contradicting `core/documentation.md`'s stated default
  (`docs/development/decisions.md`). Two projects on the same framework disagree with the
  framework itself. Also: mobos's `docs/index.md`/`README.md` reference top-level
  `guides/`/`tracks/` folders that don't exist (stale nav — separate vacuum-pass concern,
  not part of this track's scope).

Conclusion reached early in the discussion: replacing the SDLC folders wholesale with the
four literal Diataxis folders was rejected — it would just relocate the same
undisciplined-dumping-ground problem into `explanation/` (rationale, history, and research
notes would still be indistinguishable from each other, one folder over), and lose the
subject-cohesion the current tree relies on (e.g. all order-workflow docs colocated).
Diataxis has no slot for `research/`, decision logs, or ops runbooks at all — it was built
for finished-product user-facing docs, not the full SDLC.

## What changes

**Not yet decided.** This track is documenting an in-progress design discussion, per
Shmorch's "deferred intent must have a stub track" rule — no implementation yet, several
open forks remain (see below). When resolved, changes land in: `core/documentation.md`
(the doctrine itself), `templates/docs/**` (the scaffold every `init`/`auto-update` copies),
`templates/.shmorch/docs/track-template.md` (tracks split into design/dev/implementation
types, if that fork resolves toward literal subfolders), and a `Compat: backfill` row in
`core/documentation.md`'s Architecture Changelog so `auto-update.md` offers the migration to
already-provisioned projects (appadd, mobos, others).

## Proposed taxonomy (current draft, evolving)

```
docs/
├── inbox/                        # pre-ingestion holding pen — generalizes mobos's to_review/
├── project/                      # replaces state/ — in-flight, ephemeral
│   ├── sprints/
│   ├── schedule/
│   ├── process/                  # divergences from Shmorch's paved-road defaults —
│   │                              #   documented decisions + the overrides that supersede
│   │                              #   the default (branching strategy, PR merge strategy, etc.)
│   └── tracks/                   # flat — design-/dev-/impl- are filename prefixes for
│                                  #   readability, not subfolders (e.g. 20260724-design-<name>)
├── product/
│   ├── strategy/
│   ├── design/
│   │   └── concepts/             # persistent, living design thinking — built by design
│   │                              #   tracks, consumed by implementation tracks
│   ├── features/                 # permanent feature descriptions; index + subfolders for
│   │                              #   bigger features; implementation-track learnings
│   │                              #   graduate into the feature's "DONE" state
│   └── decisions/                # product-level decisions (monetization, roadmap, ux)
├── technology/
│   ├── architecture/             # graduated/stable record — includes infrastructure
│   │                              #   (no separate infrastructure/ sibling)
│   │   └── concepts/             # persistent, living architecture/infra thinking — built
│   │                              #   by design tracks
│   ├── development/
│   │   ├── concepts/             # persistent, living dev thinking — built by dev tracks
│   │   └── features/             # technical/implementation notes per feature, mirrors
│   │                              #   product/features/
│   └── decisions/                # technology-level decisions (stack, infra-ops, data)
└── reference/                    # flat topic folders, no categorical wrapper layer
    ├── research/                 # collected facts + interpretations/opinions ABOUT facts —
    │                              #   explicitly NOT design or development work. Index must
    │                              #   be well-annotated (graph-first-docs discipline).
    ├── instructions/
    │   ├── howtos/
    │   ├── tutorials/
    │   └── explanations/
    └── <topic>/                  # one flat folder per topic or vendor, named plainly —
                                   #   e.g. reference/schwab/, reference/api/ — internal vs.
                                   #   third-party is a naming choice, not a structural split
```

### Resolved this round

- Decisions live in **two** loci, not one unified log and not three: `product/decisions/`
  and `technology/decisions/`. No `project/decisions/` — project-level items were judged
  "less tangible," not decision-log material. This effectively completes the topic-split
  darkbadge already did in practice (`development/decisions/{stack,process,
  data-architecture,ux-motion,infra-ops,product-monetization}.md`) by relocating each topic
  to the branch it actually belongs to, instead of parking all topics under one branch.
- `features/` dropped entirely from `project/` (schedule-level tracking was overkill).
  Features persist permanently in both `product/` (what it is) and
  `technology/development/` (how it's built) — mirrored, each with an index pointing to a
  list or subfolders for bigger features. Implementation tracks are *driven by* features,
  not nested inside them; track closure graduates learnings back into the feature's
  "DONE" doc. This is the permanent/in-flight two-tier split (already governing `docs/` vs
  `docs/state/` at the top level) recursed one level down for the specific case of a
  feature's description vs. its build-tracking.
- `research/` stays under `reference/`, scope clarified: facts and informed interpretation
  of facts, never design/development decision-making. This resolves the objection raised
  earlier in the discussion (research files looked like "discussion," which reference was
  said to exclude) — the actual line is about *what kind* of reasoning, not whether
  reasoning is present at all.
- `guides` vs `how-tos` as separate top-level siblings was a duplication (Diataxis's own
  term is "how-to guides," one category) — consolidated under a new `instructions/` parent
  alongside `tutorials/` and `explanations/`.
- `architecture` absorbs `infrastructure` as one topic within it, not a parallel sibling —
  resolves the "(or infrastructure?)" open question from the prior round. `architecture/`
  gets a `concepts/` subfolder mirroring `development/concepts/`, fed by design tracks the
  same way `development/concepts/` is fed by dev tracks.
- `information/` wrapper dropped entirely — over-nested. `reference/` holds flat,
  plainly-named topic folders (`reference/schwab/`, `reference/api/`, etc.); whether a
  folder's content originated internally or from a third party is a naming choice, not a
  structural split. No `internal/`/`third-party/` folders.
- **Process decisions resolved**: `project/process/` — these are refinements of (or
  divergences from) Shmorch's own paved-road defaults, so they belong at the project level
  after all, just not as a `decisions/` log like product/technology. Each divergence gets a
  documented decision plus the override that supersedes the default (e.g. a non-default PR
  merge strategy). This is different from the "less tangible" project items that ruled out
  `project/decisions/` earlier — process divergences are concrete overrides, not soft
  preferences.
- **Track typing resolved**: design/dev/implementation are filename-prefix conventions on
  track directory names (e.g. `20260724-design-<name>`), not literal subfolders.
  `project/tracks/` stays flat — no change needed to `tools/track-graph-audit.sh`'s
  traversal model, only to the naming convention documented for new tracks.

### Resolved at close (2026-07-24)

1. `reference/instructions/` fully resolves the "reference also contains explanation, but
   Diataxis treats them as coequal quadrants" tension — `explanations/` is not a direct
   sibling of `reference/` itself, it's one of three children of `instructions/`, alongside
   `howtos/` and `tutorials/`. No further nesting needed.
2. Migration mechanics for already-provisioned projects (appadd, mobos, darkbadge,
   shmorch's own `docs/`) are **not** solved in this track — split off to
   `tracks/20260724-dev-docs-taxonomy-backfill` per the user's explicit instruction, to be
   designed before actual backfill implementation. The `Compat: backfill` Architecture
   Changelog row is already logged in `core/documentation.md` (2026-07-24) and points at
   that track.

## Non-goals

- Not fixing mobos's stale top-level `guides/`/`tracks/` nav references in `docs/index.md`
  — that's a plain documentarian/vacuum bug, unrelated to the taxonomy question.
- Not a general Diataxis adoption — confirmed early in the discussion that replacing the
  SDLC-phase folders with the four literal Diataxis folders was the wrong move; Diataxis is
  being applied narrowly, inside `reference/`, not as the whole tree's organizing axis.

## Work log

### 2026-07-24

Opened directly from a live design discussion (this is at least round 2 or 3 of the same
underlying question per the user, but the first time it's been written down). Two Explore
subagents audited `appadd/docs/` and `mobos/docs/` in parallel (per-file content-type
classification of every file in `architecture/` and `reference/`, plus index.md purpose
blurbs for every other section) to ground the discussion in actual file contents instead of
assumptions. Findings summarized above under Why. Proposed taxonomy iterated through several
rounds of user feedback captured under Resolved this round.

### 2026-07-24 — implemented and closed

Restructured `templates/docs/` in place: renamed/moved every existing file to its new home
(`architecture/` + `development/` → `technology/{architecture,development}/`, `product/`
gained `strategy/`, `design/`, `features/`, `decisions/`; `state/` → `project/` + new
`process/`; `to_review/` → `inbox/`; `reference/` gained `research/` and `instructions/`
{`howtos/`,`tutorials/`,`explanations/`}), splitting the old unified `development/decisions.md`
template into separate `product/decisions/` and `technology/decisions/` seeds, folding
`development/notes.md` into `technology/development/concepts/`, and genericizing the
project-specific content that had leaked into the template tree (`workflow.md`'s PHP/phpunit
specifics, `product-guidelines.md`'s trading-platform copy, `guides/`'s MoBoS/Schwab
specifics — moved to `reference/instructions/howtos/` and rewritten generically). Every new
folder got a surface-map `index.md` with `↑` links, per graph-first-docs discipline. Root
`README.md` dropped — stale duplicate of `index.md` with non-generic content.

Updated doctrine to match: `core/documentation.md` (Skeleton Principle category table,
Two-Tier Knowledge System, Front-Matter Previews, decisions-growth rule, new
`Compat: backfill` Architecture Changelog row), `shmorch-core.md` (Persistent State table,
continuous-state-updates and deferred-intent-stub-track rules, safety-rules `plan.md` path),
`templates/.shmorch/docs/track-template.md` (filename-prefix convention documented, all
example paths updated).

Backfill for already-provisioned projects explicitly **not** done here — split to
`tracks/20260724-dev-docs-taxonomy-backfill` per the user's instruction. `VERSION` bumped
to `20260724.01` as part of closing this out (skill-file changes per `core/operations.md`).
