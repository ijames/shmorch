---
loads_when: any git operation beyond a single commit — branch hygiene, pull-after-merge, rebase-before-work, never batch-merge
size: 144 lines
---

# Git Discipline

Branch hygiene rules that apply to every project Shmorch touches — skill repo and client projects alike. The goal is zero surprise conflicts at merge time and no stale branches accumulating silent divergence.

---

## The Two Invariants

**1. Main is the source of truth. Always.**
Before a branch gets any new work, it must be current with main. Not "probably current." Actually current.

**2. After a merge, pull before anything else.**
The moment a PR lands on main, every open branch is potentially stale. Treat the post-merge pull as mandatory hygiene, not an optional step.

---

### Merge strategy: never squash

Default merge strategy for all shmorch-touched projects: `gh pr merge --merge` (regular
merge, preserving commit history). Rebase merge is acceptable when a linear history is
wanted. Squash merge is never used by default — squashing destroys the commit-by-commit
story of how AI-authored code evolved, which is the audit trail a human reviewer relies on.

This assumes commit discipline is already being followed (small, single-concern commits,
real messages) — an undisciplined branch's merge-commit noise is a separate problem to fix
at the commit level, not by squashing it away.

A project may override this default with its own reasoning, recorded in that project's
`docs/project/process/index.md` or a decisions doc.

---

## Rules

### Before pushing a branch or merging its PR

`docs/project/session.md` must reflect the work on that branch before the final push/merge —
not "will update after." A merge that lands without it means the next session (or the next
agent) reads stale state.

```bash
git log --oneline -- docs/project/session.md | head -1   # last session.md commit
git log --oneline -5                                       # recent branch commits
```

If the branch has commits since session.md was last touched, run `/shmorch wrap` (Step 5
specifically) or at minimum update and commit session.md now — before the push/merge, not
after. This applies to `tools/merge-chain.sh` runs too: confirm session.md is current for
each branch before merging its PR.

### After any PR merge

Immediately, before touching anything else:

```bash
git checkout main
git pull <remote> main
```

Then, for each remaining open branch: rebase it onto the freshly-pulled main before resuming work or attempting its merge.

Never batch-merge multiple PRs without pulling main between each one. The sequence is always:

```
merge A → pull main → rebase B → merge B → pull main → rebase C → ...
```

**Use the tool, not memory, to run this sequence.** This exact sequence has been skipped
often enough in practice (merged straight through without the intermediate pull+rebase) that
relying on remembering it mid-session isn't reliable. `tools/merge-chain.sh` encodes it
mechanically for a known stack of PRs:

```bash
bash "$SHMORCH_HOME/tools/merge-chain.sh" <remote> <PR#> [<PR#> ...]
```

It merges PR N, pulls main, rebases the next PR's branch onto main, force-pushes on a clean
rebase, and stops with explicit resume instructions on a conflict (which — per the VERSION
rule above — needs a human/agent judgment call, not something a script should silently
resolve). Re-run the same command with the remaining PR numbers to continue after resolving a
conflict.

**VERSION conflicts are expected, not exceptional, during a merge sequence.** Every open
branch bumped VERSION off a now-stale main. When rebasing branch N onto a freshly-merged
main: always resolve the VERSION conflict by taking main's current value and applying
branch N's own bump tier on top of it (MAJOR/MINOR/PATCH — see `core/operations.md`'s
VERSION bump rule), not the branch's own pre-rebase bump. If branch N's tier is lower than
whatever main already moved to (e.g. main jumped a MAJOR that branch N's PATCH predates),
main's higher tier wins — never move a tier backwards. Do this as part of the mandatory
post-merge rebase, not as an ad hoc fix at each conflict.

### Before starting or resuming a branch

```bash
git fetch <remote>
git log HEAD...<remote>/main --oneline
```

If any commits appear: rebase now.

```bash
git rebase <remote>/main
```

Do this at the start of every work session on a branch, not just when a conflict forces it. A rebase against 3 commits is trivial. A rebase against 30 commits (after ignoring this for a week) is not.

### Before opening a new branch

```bash
git fetch <remote>
git checkout main
git pull <remote> main
git checkout -b <type>/YYYYMMDD-<concept>
```

The branch always forks from a current main, never from a stale local copy.

---

## The Cost of Skipping This

Each skipped pull is a tax deferred, not cancelled. The longer a branch diverges from main, the larger the eventual rebase. With multiple open branches, the cost compounds — each one that merges adds divergence for all the others. The pattern of "rebase at conflict time" means the first merge is free and every subsequent one is progressively more expensive.

Rebasing early (when divergence is small) is cheap. Rebasing late is expensive. Rebasing at conflict-force is the most expensive possible time.

---

## When Multiple Branches Are Open

Shmorch should not allow more than 2–3 branches open simultaneously on the skill repo. Open branches are a liability: they all diverge from main at the moment of each merge. If you find yourself with 4+ open PRs, merge or close them before opening new work.

---

## Encoding in Workflows

Any workflow that involves creating a PR should end with the post-merge pull sequence. Any workflow that involves resuming branch work should begin with the fetch + log check. These are not reminders — they are required steps.

See: [shmorch-core.md](../shmorch-core.md) — Skill change workflow (encodes the branch sequence)
See: [workflows/wrap.md](../workflows/wrap.md) — post-session state commit (add pull after merge)
