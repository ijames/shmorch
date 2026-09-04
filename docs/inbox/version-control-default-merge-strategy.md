# Shmorch has no default merge/rebase strategy for projects that haven't set one up

**Status:** Deferred 2026-09-04 — needs a real decision on default strategy and
where it lives (`core/operations.md` vs. a new `core/version-control.md`), not
just drafting; revisit when another parallel-track project hits the same
sequential-merge conflict DarkBadge did.

**Filed from `darkbadge` 2026-09-03**, via `docs/inbox/20260903-shmorch-merge-strategy-question.md`.

## What happened

While serially merging two DarkBadge PRs in one session, the second PR went
`CONFLICTING` right after the first landed (both touched the same file). Fixed by
rebasing the stale branch onto `main` before merging it, not by merging `main` into
the branch — but DarkBadge's own `.shmorch/AGENTS.md` Branching Discipline didn't say
which to do until that session added it as a project override.

## The gap

DarkBadge happens to have documented branching discipline (branch-per-track,
`gh pr merge --merge` for the landing merge, and now rebase-before-merge for
staleness between sequential merges). That's a per-project override in
`.shmorch/AGENTS.md`, not something Shmorch itself prescribes by default.

For a Shmorch project that hasn't set up its own merge strategy, there's no
documented default: squash vs. merge-commit vs. rebase-merge for the PR landing,
and separately, whether/how to keep stacked or parallel PR branches current against
`main` between merges. Shmorch orchestrates multi-agent parallel work
(branch-per-track is explicitly the DarkBadge pattern), which makes sequential
merges with cross-branch conflicts a predictable outcome, not an edge case — any
Shmorch project running parallel tracks will eventually hit "merge track A, now
track B conflicts/is-stale" the same way DarkBadge just did.

## Not resolved — needs a decision

- What should Shmorch's default PR-landing merge strategy be when a project
  doesn't specify one?
- Should Shmorch doctrine prescribe rebase-before-merge for stale branches by
  default when merging multiple PRs sequentially in one session?
- Where does this belong — `core/operations.md`, a new `core/version-control.md`,
  or folded into the existing branch-per-track guidance wherever that lives?
