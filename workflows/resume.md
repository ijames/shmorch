# Workflow: resume

Fast re-entry: latest session knowledge and current focus, nothing else. Use when `go`'s full bootstrap (version check, context interview, gap scanning, memory staleness check) isn't needed — you're already oriented, you just need the thread picked back up.

## When to use
- Re-entering a session that's already underway (context reset, new tab, quick check-in)
- `go` was already run this session

## Inputs
- `docs/state/session.md`, `docs/state/plan.md`

## Roles
- None — runs inline

---

## Step 1 — Read the minimum

Read `docs/state/session.md` and `docs/state/plan.md` in parallel. Nothing else — no `context.md`, no `stack.md`, no version check, no git status, no memory scan.

## Step 2 — Surface and propose

1. If `session.md` has a "Pick up immediately" or **BLOCKER** note, lead with it.
2. Otherwise, state the current task from `plan.md` in one line and propose continuing it.
3. If there's no current task, fall back to the top 2-3 backlog items as options.

Keep the whole response to a few lines — this is a reminder, not a re-orientation. If the user wants the full check (version, gaps, memory staleness), point them at `/shmorch go`.
