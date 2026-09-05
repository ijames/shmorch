# Shmorch's own repo commits doc/inbox housekeeping straight to main, contradicting git-discipline.md

**Filed from `shmorch` (self), 2026-09-05.**

## The gap

`core/git-discipline.md` (line 8) states branch hygiene "applies to every project
Shmorch touches — skill repo and client projects alike," with no stated exception.
In practice, real feature/doctrine work on this repo goes through branch → PR →
merge (every numbered PR in `docs/project/session.md`), but `check-inbox` and
session-bookkeeping commits have repeatedly landed directly on `main` instead:

- `2958bb0` — "chore(inbox): file two pe-pipeline gaps from a concurrent shming.com
  session," committed straight to `main` 2026-09-04.
- `d3adfc4` — "chore(inbox): check-inbox — defer 2 new pe-pipeline items, catch up
  session.md on PR #136," committed straight to `main` 2026-09-04.
- `56090c3` — "fix(pe): pe-synthesizer track-record update compares session date,
  not processing order," committed straight to `main` 2026-09-05 — this one isn't
  even pure bookkeeping, it's a real doc/instruction fix to `agents/roles/
  pe-synthesizer.md` and should plausibly have gone through the same branch+PR
  flow as every other doctrine change.

None of these were deliberate, documented exceptions — each just followed the
precedent of the commit before it, compounding an undocumented drift from stated
doctrine rather than a conscious call to skip branching for this class of change.

## Not resolved — needs a decision

- Does `git-discipline.md` need an explicit, scoped exception for small doc/inbox
  housekeeping commits (e.g. "check-inbox defer-only passes may commit direct to
  main; anything that changes `workflows/`, `core/`, or `agents/` content still
  goes through a branch"), or should the doctrine's "no exception" wording actually
  be enforced going forward, including check-inbox chores?
- If an exception is warranted, where does the line sit — inbox status-stamp edits
  only, or does anything under some size/impact threshold qualify?
- Either way, `workflows/check-inbox.md` Step 5 currently says nothing about
  branching at all; whatever gets decided should be stated there explicitly so this
  doesn't keep drifting by precedent.
