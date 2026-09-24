# A session rooted in the Shmorch repo performed git operations on another project's checkout

**Filed from `treeclusion` 2026-09-24.**

A Shmorch session started from the Shmorch repo itself began doing real git work — rebases, a PR, a merge — inside `/Users/james/Projects/treeclusion`, while a second agent session was actively working in that same checkout. The developer's own account: "shmorch accidentally started working on this repo from the shmorch repo. That was a mistake on shmorch's part."

Nothing was lost, but only because the interleaving happened to be benign. The question for this item is what made a SELF-repo session target a different project's working tree at all, and what stops it next time.

## What happened

On 2026-09-23, between roughly 17:37 and 17:49 PDT, two sessions operated on the same `treeclusion` checkout. Session A (this one) was merging PR #152 and cleaning up branches. Session B, rooted in the Shmorch repo, independently:

- rebased `feat/20260922-web-article-byline` onto `main` (`c135636` → `34c0817`, `2b6b684` → `3d70fc0`, `3851aeb` → `4cb251f`)
- opened and merged PR #153 from that branch (created 00:38:57Z, merged 00:41:52Z)
- checked the shared working tree out to `main`, pulled, then checked out `feat/20260915-chrome-extension-ship-prep` and started rebasing it onto `main` (`rebase (start): checkout main`, 17:42:04)
- left that rebase stopped on a conflict in `Makefile`, with the shared checkout in **detached HEAD** at `55bc475`

Session A observed the result with no idea what had caused it: `git worktree list` reporting `(detached HEAD)` where it had left `main`, a `UU Makefile`, staged files it had never touched, and a merged PR #153 it had not created. Session B then resolved the conflict and finished the rebase (17:45:15) while Session A was still diagnosing.

## Why this matters more than it looks

Session A's very next planned actions were `rm` a build artifact, edit `docs/project/tracks/index.md`, and commit. Had it not stopped to check state first, **that commit would have landed inside Session B's conflicted rebase**, in a detached HEAD, mid-conflict. The likely outcomes are a corrupted rebase, a commit stranded on no branch, or Session B resolving the conflict on top of a tree it did not expect.

Session A had also just run `git worktree remove` and `git push origin --delete` for two branches in that window. Those happened to be unrelated to Session B's work. Nothing guarantees that.

The concrete hazards from one project checkout shared by two agents:

- commits into a detached HEAD or an in-progress rebase, lost on the next `checkout`
- one session's `checkout`/`rebase` swapping the working tree out from under the other's file edits
- competing force-pushes, and branch deletions of a branch the other session is mid-operation on
- each session reading a repo state the other created and drawing wrong conclusions from it, as happened here

## The gap

Doctrine covers plenty of git discipline — branch per track, no direct-to-main, never push or switch branches without confirmation — but all of it assumes **one session, one repo**. There appears to be nothing that:

1. binds a session's git operations to the project it was started in, so a session whose cwd is `$SHMORCH_HOME` cannot rebase, commit, PR or merge in `/Users/james/Projects/<other>`; and
2. detects that another agent is already live in a target checkout before touching it.

Worth investigating specifically: what led Session B to act on `treeclusion` at all. Plausible candidates, none verified — `$SHMORCH_SELF` detection failing so SELF-repo mode resolved paths into the last-used project; a `go`/`resume` run picking up `treeclusion`'s `session.md` or timelog from a stale pointer; or `tools/` scripts (`merge-chain.sh`, `commit-session-state.sh`, `checkpoint.sh`) resolving a repo root by search rather than from an explicit, session-pinned path. The reflog shows `pull origin main -q` — a `-q` invocation typical of the tooling rather than a hand-typed command, which points at a script rather than a developer action.

## Possible directions

Not scoped, and the right answer may be one of these rather than all:

- A session-pinned repo root, resolved once at session start and asserted before every write operation; a mismatch stops and asks rather than proceeding.
- A liveness check before git writes in a checkout: an in-progress rebase/merge (`.git/rebase-merge`, `.git/MERGE_HEAD`), a detached HEAD, or a recent foreign reflog entry means stop and surface it, not continue.
- Refuse cross-repo git writes outright from a SELF-repo session, since Shmorch working on Shmorch is the case most likely to have loose path resolution.

## Related

`agent-window-confusion.md` (filed from `JKAM/system` 2026-09-18) covers the adjacent case where the *developer* addressed the wrong project's window and the agent worked blind. This item is the other direction: the agent chose the wrong repo on its own initiative, and the target repo had another agent live in it. A fix for one does not obviously fix the other, but they likely share a "which project am I actually in, and is anyone else here" answer.
