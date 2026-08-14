---
loads_when: user ran `/shmorch touch` — a silent state-sync, not a session entry point
size: 45 lines
---

# Workflow: touch

Reconcile `session.md` and `plan/` against reality, then stop. No SESSION_START/END stamps
(this isn't a session boundary), no context interview, no gap scanning, no summary narration
beyond what changed. If nothing's drifted, say so in one line and stop.

## When to use
- Mid-session, to keep state files honest without invoking `wrap`'s full close-out
- Anywhere `resume`'s cross-check (Step 2 of `workflows/resume.md`) would flag drift, but you
  want it fixed inline instead of just surfaced

## Inputs
- `docs/project/session.md`, `docs/project/plan/`
- `git branch --show-current`, `git log --oneline -10`, `gh pr list --state merged --limit 5`
  (best-effort; skip silently if `gh` fails or isn't authenticated)
- `find docs/project -newer docs/project/session.md` — files touched since the last log entry

## Roles
- None — runs inline

---

## Step 1 — Read and cross-check

Read `session.md` and `plan/` in parallel, then run the same drift check as `resume` Step 2:
does the branch match what `session.md` calls "in progress"? Any merged PR or commit not named
in the last entry? Any file under `docs/project/` newer than `session.md` itself?

## Step 2 — Reconcile, don't rewrite

If nothing drifted: say so in one line (`session.md and plan/ match repo state — nothing to
touch.`) and stop.

If something drifted, apply the minimum edit that makes the docs true again:
- Check off `plan/` items git shows as merged/shipped
- Append one line to `session.md`'s latest entry noting what happened since it was last
  written (commits, merged PRs) — don't rewrite the entry, extend it
- Flip a track's status if the log confirms it closed

Don't touch `context.md`, `stack.md`, acceptance criteria, or anything outside
`session.md`/`plan/` — that's `wrap`'s job, not this one.

## Step 3 — Report

One or two lines: what was out of sync, what got fixed. No re-orientation, no next-step
proposal — that's `resume`'s job if the user wants it next.
