↑ [Inbox](index.md)
**In this section:** [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# Merge strategy default (never squash) — and a process gap in how this was almost added

**Issue (2026-08-05):** On appadd/DarkBadge, the developer stated a durable preference
after a regression-fix session that shipped 6 hand-split, single-concern commits:
"Since AI is doing the programming, the story of how the code evolved is critical to
humans to see... No squash merges. Rebase merges might be ok, but the punctuated
sequential standard merge makes the path very clear." He asked for this to be recorded
both as a project decision (done — `docs/technology/development/decisions/process.md`
in that repo) and as "a core principle of shmorch."

Acting on the second half, the session `cd`'d into `$SHMORCH_HOME`, branched
(`docs/20260805-no-squash-merge-policy`), edited `core/git-discipline.md` directly, bumped
VERSION, and opened a PR (#96) against the skill repo — while the actual working session
was in a *different* project's repo the whole time. The developer caught this: "The
process for Shmorch is to put the information into inbox to let shmorch sort it out
without contention or conflicts between branches all writing to shmorch." PR #96 was
closed unmerged and the branch deleted; this file is the correct re-filing.

**What to consider:**
- The merge-strategy proposal itself: **regular merge (`gh pr merge --merge`) as the
  paved-road default across all Shmorch-touched projects; rebase merge acceptable when a
  linear history is wanted; squash merge never used.** Rationale is specifically about
  AI-authored code — commit-by-commit history is the audit trail a human reviewer has for
  *how* the code evolved, and squash destroys it permanently at branch-delete time. This
  only holds where commit discipline is already enforced (small, single-concern commits,
  real messages) — an undisciplined branch's merge-commit noise is a different problem.
  A candidate landing spot is `core/git-discipline.md`, as a new section alongside "The
  Two Invariants," with an explicit per-project override path (project's own
  `docs/project/process/index.md` or decisions doc) for cases with a specific reason to
  diverge.
- The process gap this surfaced: **no session outside `$SHMORCH_HOME` should branch,
  commit, or push against the skill repo directly**, even when it has correctly diagnosed
  a real skill gap. That project has standing to *message* shmorch, not mutate its
  internals — direct edits from N different client-project sessions is exactly the
  "contention/conflicts between branches all writing to shmorch" the developer flagged.
  The fix is procedural, not just this one instance: a client-project session that
  identifies a skill-doctrine gap should write straight to
  `$SHMORCH_HOME/docs/inbox/<concept>.md` (this file is the pattern) and stop — no
  branch, no PR, no VERSION bump from outside the skill repo. Only a session actually
  running *in* `$SHMORCH_HOME` should pick up an inbox item and run the branch → PR →
  developer-merge flow in `core/operations.md`. This rule likely belongs in
  `core/operations.md` (near the existing skill-change workflow) and/or
  `workflows/self-improve.md` (which currently only distinguishes "skill-level" vs.
  "project-level" changes, not "which repo is this session standing in").
- Not yet resolved — both the merge-strategy change and the cross-repo-discipline rule
  are still proposals; a `self-improve` pass (or a session native to `$SHMORCH_HOME`)
  should evaluate, then apply via the normal branch → PR → merge flow from inside the
  skill repo.
