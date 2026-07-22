# Workflow: resume

Fast re-entry: latest session knowledge and current focus — plus a cheap staleness check, since `resume`'s whole premise (just cleared, mid-session) means real time may have passed and `session.md`/`plan.md` may not reflect it. Use when `go`'s full bootstrap (version check, context interview, gap scanning, memory staleness check) isn't needed — you're already oriented, you just need the thread picked back up *correctly*.

## When to use
- Re-entering a session that's already underway (context reset, new tab, quick check-in)
- `go` was already run this session

## Inputs
- `docs/state/session.md`, `docs/state/plan.md`
- `git branch --show-current`, `git log --oneline -10`, `gh pr list --state merged --limit 5`
- Most-recently-modified files under `docs/state/` and the working tree (cheap signal for in-flight work never logged)

## Roles
- None — runs inline

---

## Step 1 — Read the minimum

Read `docs/state/session.md` and `docs/state/plan.md` in parallel. No `context.md`, no `stack.md`, no version check, no memory scan.

## Step 1.5 — Stamp session start

`resume` is a session entry point just like `go`, but historically never stamped the timelog — post-`/clear` sessions then got SESSION_START and SESSION_END written in the same second at wrap, making `duration.sh` output meaningless. Stamp now, unless today's timelog already has a SESSION_START after the last SESSION_END (i.e. the session is already open):

```bash
LAST=$(grep "SESSION_" docs/state/timelog.md 2>/dev/null | tail -1 || true)
if [[ "$LAST" != *"SESSION_START"* ]]; then
  bash "$SHMORCH_HOME/tools/timelog.sh" "SESSION_START" "resume: <current task one-liner from session.md>"
fi
```

## Step 2 — Cross-check, don't trust blindly

`session.md` and `plan.md` are only as fresh as the last `/shmorch wrap` or in-the-moment edit. A `/clear` is invisible to shmorch — nothing runs automatically after it — so the gap between "what these docs say" and "what main actually looks like" can be hours or days, even mid-sprint. Run this cross-check every time, not just when something feels off:

1. `git branch --show-current` + `git log --oneline -10` — does the branch match what session.md says is "in progress"? Are there merge commits or PRs referenced in the log that session.md's latest entry doesn't mention?
2. `gh pr list --state merged --limit 5` (best-effort; skip silently if `gh` fails or isn't authenticated) — any merged PR not named in session.md's last entry is a sign docs are behind reality.
3. Most-recently-touched files (e.g. `git log -1 --name-only`, or `find docs/state -newer docs/state/session.md`) — a cheap clue toward work that happened but was never logged, especially uncommitted or just-committed changes the session log doesn't know about.

If branch/log/PRs line up with session.md's account: proceed to Step 3 normally, no need to mention the check.

If they don't line up: say so plainly before proposing next steps — name what's newer than the docs (commits, merged PRs, branch state), not just "docs may be stale." Offer to write a quick catch-up entry, but don't block on it — the user can say "skip it, just tell me what's next."

## Step 3 — Surface and propose

1. If `session.md` has a "Pick up immediately" or **BLOCKER** note *and it's still consistent with the cross-check*, lead with it.
2. Otherwise, state the current task — from `plan.md` if it checks out, or from what git/PRs actually show if it doesn't — in one line and propose continuing it.
3. If there's no current task, fall back to the top 2-3 backlog items as options.

Keep the whole response to a few lines — this is a reminder, not a re-orientation. If the user wants the full check (version, gaps, memory staleness), point them at `/shmorch go`.
