# Shmorch's own repo commits doc/inbox housekeeping straight to main, contradicting git-discipline.md

**Filed from `shmorch` (self), 2026-09-05. Resolved 2026-09-08.**

## Resolution

Enforce the doctrine's existing "no exception" wording — no carve-out. Root
cause found 2026-09-08 (a fresh direct-to-main commit, caught by the
developer, repeated this exact pattern): `templates/.githooks/pre-commit`
already existed to block this, but shmorch's own repo (`shmorch-ln`) never
had it installed — no `.githooks/` directory, no `core.hooksPath` set. The
hook wasn't a policy gap, it was dead code for this repo. Fixed:

- `.githooks/pre-commit` added to this repo, `templates/.githooks/pre-commit`
  updated to match — the previous state-file/decisions/`.shmorch/` exemption
  removed entirely; the hook now blocks **any** direct commit to `main`/`dev`,
  no file-type carve-out.
- `core/git-discipline.md` gained an explicit "no exceptions, enforced by
  hook" note requiring `.githooks/` + `core.hooksPath` to actually be set,
  not just templated.
- `workflows/check-inbox.md` Step 5 now states check-inbox commits branch
  like everything else.
- `core.hooksPath .githooks` still needs to actually be run once in this
  clone (`git config core.hooksPath .githooks` — not run automatically per
  this session's git-config restriction; do it manually or via `/shmorch
  init`/`auto-update`'s existing hook-sync step).

Related follow-up filed separately: `hooks-self-install-gap-and-readme-drift.md`
— the Claude Code `PreToolUse` hook has the same self-install gap, and
README's description of what that hook blocks is stale.

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
