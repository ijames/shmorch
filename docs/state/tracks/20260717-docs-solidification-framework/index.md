↑ [Shmorch Plan](../../plan.md)
→ `core/documentation.md` (Architecture Changelog) + `workflows/auto-update.md` (Step 2.8) +
`agents/roles/vacuumer.md` + `tools/stop.sh` + `workflows/orient.md` + `templates/.shmorch/AGENTS.md`

# Track: Docs solidification — continuous placement + version-triggered backfill

**Status:** Open
**Opened:** 2026-07-17
**Domain:** Documentation architecture

## Why

Originally scoped as a single new command (`solidify`) that would restructure a messy
`docs/` tree in one sweep. Two rounds of user feedback rejected that framing entirely and
split it into two different, real concerns:

1. **Placement is a creation-time concern, not a cleanup-later one.** A doc that lands in
   the wrong skeleton location is waste the moment it's written — same category as vacuum's
   existing waste-hunting (stale TODOs, dead code), just structural instead of textual. It
   should not need a separate command anyone has to remember to run; it belongs to the
   `vacuumer` role and should fire automatically (optionally) around the work, not on a
   deferred manual pass.
2. **Architecture-version backfill is a real, harder problem.** `core/documentation.md`
   doctrine is read live from `$SHMORCH_HOME` by every project — the *rules* are always
   current, no sync needed. What can't self-update is *existing docs content* written
   under an older rule (e.g. `docs/state/*.md` files that predate the front-matter
   convention). When the rule set changes in a way that invalidates existing content, that
   needs a deterministic, opt-in migration path — the developer explicitly asked "when we
   change the architecture of the knowledge base, existing projects should backfill to
   that if they give the OK," and flagged not knowing the general mechanism.

## What changes

**Concern 1 — continuous placement (`agents/roles/vacuumer.md`, `tools/stop.sh`, `workflows/orient.md`):**

- `vacuumer` gained a "docs placement" hunt category: correct `docs/<category>/`, `index.md`
  linkage, `↑`/`→` links, front-matter presence — checked on files the current turn touched,
  not swept for later.
- An **optional** reminder wired into the existing `Stop` hook (`tools/stop.sh`) — not a new
  hook file, not a new command. If `docs/` files changed this session and the project has
  opted in, the hook prints a one-line nudge to apply the vacuumer check before `/shmorch wrap`.
  The hook only ever prints a reminder — it has no judgment of its own; the actual placement
  check is still a reasoning step Shmorch performs, same pattern as the existing
  `session-start.sh` context injection.
- Opt-in toggle lives in `.shmorch/AGENTS.md` under "Docs Placement Hook" — asked once during
  `orient.md`'s Context Setup interview, default disabled, editable any time.

**Concern 2 — version-triggered architecture backfill (`core/documentation.md`, `workflows/auto-update.md`):**

- `core/documentation.md` gained an **Architecture Changelog** table: dated rows, each tagged
  `Compat: additive` (no backfill needed) or `Compat: backfill` (existing docs no longer
  conform) plus an exact `Backfill scope` cell.
- No semver was introduced. The existing `VERSION` format (`YYYYMMDD.NN`) already carries a
  date — that's the only comparison axis needed: a changelog row dated after a project's
  last-synced `VERSION` date means that project predates the rule. Decision: reuse what
  exists rather than add a parallel versioning scheme for one narrow purpose.
- `auto-update.md` Step 2.8 reads the changelog, finds rows the project predates, and offers
  each one individually — "yes/no/later" — scoped to exactly that row's `Backfill scope`
  instruction. Never a bulk "restructure everything" pass; each row is its own small,
  reviewable migration, and declined rows are reported (not silently dropped).

## Non-goals

- No general-purpose "fix any messy docs tree" tool. If a project's docs never followed the
  skeleton at all (legacy import, no prior shmorch), that's `documentarian`'s legacy-mode
  reverse-engineering job, or a manually-scoped one-off — not something this track builds.
- Doesn't touch `20260525-graph-first-docs` (target shape design) or `20260717-state-store-shape`
  (backend format) — this track is the mechanism that keeps existing content converged on
  whatever those land on, via the changelog, once they land.

## Work log

### 2026-07-17
Opened as a general "solidify" command; user feedback (two rounds) rejected the
standalone-command framing and repointed it as (1) an ongoing vacuumer-role concern fired via
the existing `Stop` hook, optional, and (2) a version-triggered, changelog-driven backfill
folded into `auto-update.md` rather than a new workflow. Implemented both: `commands/solidify.md`
and `workflows/solidify.md` deleted; `core/documentation.md` Architecture Changelog added with
the front-matter convention logged as the first `backfill`-tagged entry; `auto-update.md` Step
2.8 added; `vacuumer.md` gained the docs-placement hunt category; `tools/stop.sh` gained the
opt-in reminder; `orient.md`'s interview and `templates/.shmorch/AGENTS.md` gained the opt-in
toggle.
