# Cross-repo inbox filing is messaging — give it a command, and review inboxes in a worktree

Filed from `treeclusion` 2026-09-24.

## What happened

A treeclusion session needed to file an inbox item into the shmorch repo. `check-inbox.md` is unambiguous that inbox changes go through a branch and a PR — "There is no 'just inbox housekeeping, commit direct to main' allowance" — so the filing had to branch shmorch. But the shmorch checkout was sitting on its own active branch at the time, and switching it would have been both a safety-rule violation and a good way to lose someone else's work in progress.

What was done instead: `git worktree add -b docs/<slug> <tmpdir> js/main` from inside the shmorch repo, write the inbox file and its index entry there, commit, push, open the PR, remove the worktree. The shmorch checkout never moved. Nothing was switched, nothing was stashed, no confirmation was needed for a branch change that never happened.

The developer's reaction on seeing it: "you used a worktree for the inbox branching off of main? That is actually really solid!!!"

## The two proposals

**1. `/shmorch message <project>` — name the thing.** Filing an item into another project's inbox is not inbox housekeeping, it is *messaging another project*. It deserves a command rather than being re-derived by each session that happens to need it. The command does exactly the sequence above, for any repo: resolve the target project's repo and its `main`, create a throwaway worktree off it, write `docs/inbox/<slug>.md` plus its `docs/inbox/index.md` entry, commit with the standard trailers, push, open the PR, remove the worktree. The sender's own checkout is untouched, and so is the recipient's.

Details worth deciding when this is picked up: how `<project>` resolves to a repo path (a registry? `~/.shmorch/` config? the personal-profile's project aliases?), which remote name to push to when a repo has several (`js` in shmorch's case, not `origin`), whether the item carries a standard "filed from `<project>` <date>" header automatically (the index already uses that convention by hand), and whether `/shmorch message` without a target project means "file into my own inbox" or is an error.

**2. `check-inbox` should gather, not browse.** Today the workflow reads whatever is sitting in `docs/inbox/` on the current branch. Once filing happens by PR, the inbox is spread across open branches, and reviewing on any one of them means reading a polluted, arbitrary slice. The workflow should instead collect the open inbox branches, merge them into a scratch branch off `main` — again, plausibly in a worktree, so the reviewer's checkout is not disturbed either — and triage the whole set together. Triage decisions then land as one reviewed change rather than N drive-by merges.

## The general principle behind both

The developer's framing, verbatim: "These nice exclusivly divided tasks are fabulous for worktrees, unlike the blast radius of a design and feature lifecycle."

A worktree is cheap and safe exactly when the task's file set is small, disjoint from what the main checkout is doing, and finished in one sitting — filing a message, reviewing an inbox, a docs-only fix. It is a poor fit for a feature track, where the work spans the codebase, runs across sessions, and needs the full dev environment. That distinction is not written down anywhere in the doctrine today; if either proposal above is adopted, it is worth stating once in `core/git-discipline.md` so future sessions reach for a worktree in the first case and not in the second.

## Related

- `agent-window-confusion.md` — its third option, "cross-project inbox routing," is the same need arrived at from the other direction. These two should be resolved together.
- `core/git-discipline.md` — the no-direct-to-main rule that makes cross-repo filing need a branch at all.
- `workflows/check-inbox.md` — proposal 2 rewrites its Step 1.
