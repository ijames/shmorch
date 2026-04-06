# Workflow: Build

## Steps

1. Set plan STATUS: IN_PROGRESS in `shmorch/state/plan.md`
2. Large features: spawn parallel implementers per module/layer
3. Small features: implement directly
4. Before committing — run **Definition of Done** checklist (see below)
5. Commit as a complete unit: code + tests + docs + track update in one commit
6. Run vacuum workflow
7. Set STATUS: DONE, update `shmorch/state/session.md`
8. Run `/shmorch checkpoint`

---

## Definition of Done

Run through this checklist before every commit. Do not split these into separate commits — they belong together as a complete unit of work.

### 1. Tests

- Did any new public methods get added or changed?
  - If yes: are there tests covering the new behavior?
  - If no tests: write them now, or get explicit user sign-off to defer
- Run the test suite and confirm no regressions

(See `shmorch/CLAUDE.md` for the project-specific test command.)

### 2. Documentation

- Did any public API, architectural pattern, or data model change?
  - If yes: is `docs/architecture/` or `docs/tech/` updated to reflect it?
- Did a new service, model, or exception type get introduced?
  - If yes: is it documented in the relevant architecture doc?
- Does `docs/tracks/` need a new entry, or an existing one updated?

### 3. Track

- Is this work tied to an open track step in `docs/tracks/`?
  - If yes: mark the step done or note progress in the track file
  - If no track exists and this is non-trivial work: create one now
- Update `shmorch/state/plan.md` to reflect completion

### 4. Commit grouping

All of the above belong in **one commit per logical unit of work**. If tests or docs are missing, do not commit the code alone. Either finish them or create a track step to complete them and note the gap explicitly.

(See `shmorch/CLAUDE.md` for the project-specific commit example.)

---

## Checklist Summary

Before running `/shmorch commit`:

- [ ] Tests written and passing for all new/changed public code
- [ ] Docs updated if public API or architecture changed
- [ ] Track step marked done (or new track created)
- [ ] All related files staged together as one unit
