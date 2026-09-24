# Plan items have no defined graduation path — pruning them loses information

**Status:** Deferred 2026-09-23 — keep at this path: `workflows/touch.md` links here as the gate on plan-pruning (PR #149). Revisit when writing the plan → track → destination lifecycle rule, with worked examples from DarkBadge.

**Filed from `darkbadge` 2026-09-17.**

## What happened

The just-upgraded `touch` workflow (see `close-tracks-on-merge.md` and
`track-info-retention-vs-graduation.md`) added a rule: sweep `plan/` items
already marked `[x]` into `plan/completed-tasks.md` so they stop sitting in
their source file. Ran it for real against DarkBadge: moved 22 `[x]` lines
out of 6 `plan/*.md` files into `completed-tasks.md`.

Developer's reaction: "I actually don't understand why I'd want to delete
completed plans... this is still not right, this is a Shmorch concern
hitting all repos that might require upgrading the document flow." Reverted
the sweep pending a real answer.

## The gap

`core/documentation.md`'s Skeleton Principle assumes a track's (or, by
extension, a plan item's) *knowledge* graduates into a `docs/<category>/`
doc before the source item goes away — the track-closing process explicitly
lists "Write knowledge into the `→ destination` doc(s)" as step 1, before
"Update `plan/` (move to Completed)" as step 3.

Checked whether that actually holds for DarkBadge's `plan/` items: of 10
docs in `docs/product/features/`, exactly **1** back-links to a plan item
(`badge-hover.md` → "Plan item: BadgeMini hover... in plan.md § Core Display
& Tile UX"). The other 9 feature docs, and every closed track examined this
same session, either never had a plan-item link or never had it stated.

The `[x]` lines being archived carry real, specific implementation detail —
exact commit hashes, CSS class names, before/after behavior, decision
rationale — that isn't restated anywhere else. `plan.md`/`plan/*.md` items
were never given a `→ destination` header the way tracks were. So "archive
the plan item" silently discards the only surviving record of *how* the item
was actually done, unlike a track close (which at least nominally checks the
destination first).

There's also a broader unresolved confusion the developer named directly:
the relationship between **plan** (informal flat `[ ]`/`[x]` backlog buckets,
predates tracks), **track** (formal 5-phase unit, permanent directory),
**feature** (permanent product-facing doc), and **project** (the whole
ephemeral `docs/project/` tree) isn't written down anywhere as a single
model — each is documented separately in `core/documentation.md` and
`workflows/build.md`, but nothing states how an item is supposed to move
between them, or when a plan item is expected to *become* a track versus
just get done informally and checked off.

## Not resolved — needs a decision

- Should a `plan/` item require a `→ destination` (a feature doc, an
  architecture doc, or an explicit "no doc needed, this is cosmetic")
  before it can be archived/removed, mirroring how tracks already work?
- If a plan item's implementation detail has nowhere else to live, should
  archiving *preserve* that detail verbatim (current `completed-tasks.md`
  approach, once trusted) rather than assume it graduated?
- Should `plan/` items above some complexity threshold be required to
  become tracks rather than staying informal one-liners forever — i.e. is
  the actual bug that DarkBadge has 20 `plan/*.md` files acting as a
  permanent parallel backlog system that competes with tracks instead of
  feeding them?
- Is a single explicit doc — "how work items move: plan → track → feature/
  decision, and when each transition is required" — needed as its own
  `core/` file, since this is confusing enough across projects that
  `touch`'s pruning rule shipped without noticing the gap?

This is cross-repo doctrine, not a DarkBadge-local fix — the same ambiguity
would hit any project using `plan/` buckets alongside tracks. Needs worked
examples before any workflow enforces plan-item pruning again. The `touch`
plan-pruning rule added 2026-09-16 should stay dormant (or be reverted)
until this resolves — re-running it as-is would repeat the same mistake.
