# Candidate doctrine addition: expand / migrate / contract as a named tenet

**Status:** Resolved 2026-09-14 — see Resolution below.

**Filed:** New, filed from `darkbadge` 2026-09-07, developer-directed — not a
one-off track note, an explicit ask to codify this in Shmorch itself so it
applies to every project, every large shift, not just this one.

## What the developer asked for (verbatim intent)

> "The practice I'm trying to establish here for this sort of large shift is
> critical because it could and possibly should happen all the time allowing
> for agility and agile refactoring through dark launching and feature flags,
> stages or otherwise... we should be able to build out a release where
> nothing changes until the flag is flipped (and can be flipped back ideally)
> where we are double writing, and then make sure the new structure is
> complete, then another switch would come when all components are on the
> new data and new SQS message types, but can still flip back. And after
> that settles, a final release which removes the crufted unused code."

## Why `core/progressive_delivery.md` doesn't already cover this

That file's Toggle Types / Scale Ladder / Dark Default Rule / Codify Phase
sections are about **code-path** visibility (is the feature dark or live to
users). This pattern is about **data and message-shape** authority — which
storage column/table, or which SQS payload shape, is the source of truth —
and requires a stronger guarantee: not just "absence means dark" at launch,
but "every non-final stage must be safely flippable in *both* directions,
with no data loss," because the old and new representations coexist and both
must stay correct throughout the bake period. A single Toggle Types table
doesn't capture that the flag here gates a *migration's own progress*, not
just a feature's visibility.

## Proposed tenet — three stages, named

1. **Expand (dark).** Build the new structure (column, table, SQS message
   field) fully alongside the old. Nothing observable changes. If the new
   structure needs data the old one already produces, dual-write both on
   every write — the new structure accumulates real data while the old path
   stays authoritative and untouched. No flag is even required at this stage
   if dual-write is unconditional and cheap; a flag is required once any
   *read* path could branch (see stage 2).
2. **Migrate / cutover (flagged, reversible).** Once the new structure is
   verified complete and correct (e.g., a parity check against the old
   path's output), flip a flag so reads — and, for message-shape changes,
   newly-produced messages — move onto the new structure. The old structure
   keeps being written and kept intact throughout this stage purely as a
   safety net. **The flag must be flippable back to stage-1 behavior at any
   point in this stage with zero data loss**, since the old path never
   stopped. This is the property that makes the migration itself agile
   rather than a single big-bang cutover.
3. **Contract (one-way, its own release).** Only after stage 2 has baked and
   settled: a final, explicit release removes the old structure, the
   dual-write, the old read path, and the flag itself (this is Codify, per
   the existing Codify Phase section — same idea, applied to a migration
   rather than a feature). Not reversible, and deliberately its own release,
   never bundled into stage 2's cutover.

## Concrete evidence this pattern is already load-bearing, informally

- DarkBadge's `job_type_taxonomy_v2` design
  (`docs/project/tracks/20260827-job-attempts-history/index.md`, "Decided
  (developer, 2026-08-27)" item 7) already does stages 1–2 correctly: dual
  `key`/`legacy_key` registry entries, worker dispatch accepting both v1 and
  v2 `job_type` strings unconditionally, additive-only migration, flag
  gating only which string the API *writes* — with contract (dropping the
  v1 keys, narrowing the CHECK) explicitly deferred to a future track. This
  was arrived at case-by-case, not by naming the pattern.
- The same track hit a live case needing this shape *while scoping it*: a
  decision about whether `activity_link_attempts` (a per-attempt history
  table) can be replaced by a single `last_attempted_at` column on
  `activities`. The first pass at resolving it jumped straight to "deprecate
  outright" — the developer corrected this to demand the full three-stage
  treatment instead (expand: add the column, dual-write; migrate: flip a
  flag so the eligibility query reads the column, keep dual-writing;
  contract: a later track drops the old table). See that track's spec.md /
  index.md for the applied version.

## Not resolved — needs a decision

- Should this become a new top-level section in `core/progressive_delivery.md`
  (e.g. "Data & Message-Shape Migrations — Expand / Migrate / Contract"),
  cross-referenced from Toggle Types since it's a related but distinct
  concept (data/schema authority vs. code-path visibility)?
- Should the Build Workflow Hook / "at spec time" required-answers list gain
  a parallel checklist item for migrations specifically: "does this
  introduce a second storage/message shape? If so, name its three stages
  and each stage's flip-back guarantee before implementation begins"?
- Is a dedicated flag *type* worth adding to the Toggle Types table (a
  "Migration toggle" — owner: engineering, lifespan: until stage-2 verified,
  distinguishing feature from data-migration toggles at a glance)?

## Resolution

Applied 2026-09-14, all three open questions answered yes: a new
"Data & Message-Shape Migrations — Expand / Migrate / Contract" section was
added to `core/progressive_delivery.md` (cross-referenced from Toggle Types),
a **Migration toggle** row was added to the Toggle Types table, and the Build
Workflow Hook gained the parallel required-answer for migrations specifically.
