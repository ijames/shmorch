# Git Discipline

Branch hygiene rules that apply to every project Shmorch touches — skill repo and client projects alike. The goal is zero surprise conflicts at merge time and no stale branches accumulating silent divergence.

---

## The Two Invariants

**1. Main is the source of truth. Always.**
Before a branch gets any new work, it must be current with main. Not "probably current." Actually current.

**2. After a merge, pull before anything else.**
The moment a PR lands on main, every open branch is potentially stale. Treat the post-merge pull as mandatory hygiene, not an optional step.

---

## Rules

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
