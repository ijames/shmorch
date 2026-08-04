---
status: Active
updated: 2026-08-04
summary: Switch shmorch VERSION from date-based (YYYYMMDD.NN) to semantic versioning (MAJOR.MINOR.PATCH), now that the skill is on a public repo. Includes a one-time transition notice in auto-update.md for projects still on the old format.
---

↑ [core/operations.md](../../../../core/operations.md)
→ [core/operations.md](../../../../core/operations.md), [core/documentation.md](../../../../core/documentation.md), [core/git-discipline.md](../../../../core/git-discipline.md)

# Track: Semver versioning

**Status:** Active
**Started:** 2026-08-04
**Domain:** shmorch skill infrastructure (VERSION scheme, auto-update)

## Why

`VERSION` has always been `YYYYMMDD.NN` — fine for a single-developer local skill, where
"today's date" was a sufficient identity. Now that shmorch is a public repo, other people
consume it and need to reason about what kind of change a version bump represents (breaking
restructure vs. new capability vs. a tweak) without reading the changelog. A date tells you
*when*, not *what kind*.

## What changes

- `VERSION` moves from `YYYYMMDD.NN` to `MAJOR.MINOR.PATCH` (semver), starting at `1.0.0` —
  the switch itself counts as the first MAJOR bump under the new scheme.
- `core/operations.md` — VERSION bump rule rewritten:
  - **MAJOR** — backfills (a `Compat: backfill` Architecture Changelog entry) or
    template/scaffold structure changes; also any future change to the versioning scheme
    itself.
  - **MINOR** — additions to the skill suite (new command, workflow, role).
  - **PATCH** — tweaks to existing skill files that don't fit MAJOR or MINOR.
- `core/git-discipline.md` — VERSION conflict rule updated: on a collision between two
  branches that both bumped off stale `main`, take main's value and apply whichever of the
  two branches' bump *tiers* is more significant (not just "increment `.NN`").
- `core/documentation.md` — replaces the "no separate semver scheme" line; Architecture
  Changelog keeps its `Date` column for legacy (pre-1.0.0) rows, and rows added after the
  cutover carry a `Since: <semver>` value instead.
- `workflows/auto-update.md` Step 1 — detects a project still on the legacy
  `^[0-9]{8}\.[0-9]+$` format syncing against a semver skill version, and prints a one-time
  explanation of the new scheme before continuing (the "launching update" the developer
  asked for) — not a silent format swap.
- `workflows/auto-update.md` Step 1.9 — backfill-detection logic branches on which format the
  *project's pre-update* VERSION is in: legacy → compare against changelog `Date` rows as
  today; semver → compare against changelog `Since` rows using numeric MAJOR.MINOR.PATCH
  ordering (plain bash tuple comparison, no new tooling).
- `workflows/self-improve.md` — the two inline "Bump VERSION to `YYYYMMDD.NN`" lines point at
  `core/operations.md`'s rule instead of duplicating the old format.
- Everything else that matches `YYYYMMDD` in the repo (branch names, report filenames, track
  directory names) is unrelated to `VERSION` and is out of scope — those are naming
  conventions, not version parsing.

## Work log

### 2026-08-04

Raised while resolving carried-over session state: a semver-bump request had sat deferred
across three sessions (2026-07-21 → 2026-07-31 → today). Confirmed with the developer this
now matters because the repo is public. Scoped the MAJOR/MINOR/PATCH definitions with the
developer directly (backfills/template-structure = MAJOR, skill-suite additions = MINOR,
tweaks = PATCH, scheme changes themselves = MAJOR). Found the real blocker on the way in:
`workflows/auto-update.md` Step 1.9 parses the date straight out of `VERSION`
(`PROJECT_DATE="${PROJECT_VERSION%%.*}"`) to drive Architecture Changelog backfill
detection — pure semver breaks that unless the comparison axis changes too. Developer chose
semver going forward, transition explained to the user in-band when auto-update first hits
a legacy-format project, rather than either keeping a hidden date suffix or dropping backfill
detection outright. Next: implement the six changed files, verify Step 1.9's bash tuple
comparison logic manually against a couple of sample version pairs, open the PR.
