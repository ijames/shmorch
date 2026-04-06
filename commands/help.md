# Command: help

Show available shmorch commands, then suggest what to do next based on project state.

## Step 1 — Print commands table

| Command | Description |
|---|---|
| `/shmorch init` | Initialize a shmorch workspace in a project directory |
| `/shmorch go` | Start a session — read state, orient, ask what to do |
| `/shmorch wrap` | Wrap up a session — stamp end time, summarize, update state files |
| `/shmorch commit` | Track-aware commit — groups shmorch state + code by active track |
| `/shmorch vacuum` | Scan for TODOs, dead code, empty tests — review and clean |
| `/shmorch checkpoint` | Quick-save shmorch state files to git |
| `/shmorch update` | Sync this project's shmorch files to the latest skill version |
| `/shmorch help` | Show this help |

---

## Step 2 — Suggest next action based on project state

Inspect the shmorch directory to determine what's most useful right now. Do all checks in parallel.

**Check A — Is shmorch initialized?**
Does `shmorch/state/context.md` exist?
- No → suggest `/shmorch init`; skip remaining checks.

**Check B — Is context filled in?**
Read `shmorch/state/context.md`. Is it still placeholder text (contains `<!-- -->`  with no real content)?
- Yes → suggest the user fill in `shmorch/state/context.md` before starting, or run `/shmorch go` which will prompt them.

**Check C — Active plan?**
Read `shmorch/state/plan.md`. Is there a current task with STATUS other than `_(none yet)_`?
- Yes, IN_PROGRESS → "You have an active task: [task name]. Run `/shmorch go` to resume."
- Yes, PENDING → "There's a task queued: [task name]. Run `/shmorch go` to start it."
- No task → "No active task. Run `/shmorch go` to plan what to work on."

**Check D — Uncommitted changes?**
Run `git status --short 2>/dev/null | head -5`. Any output?
- Yes → "There are uncommitted changes. Consider `/shmorch commit` or `/shmorch go` to review."

**Check E — Stale vacuum reports?**
Any files matching `shmorch/state/vacuum-report-*.md`?
- Yes → "Unreviewed vacuum report(s) in shmorch/state/. Run `/shmorch vacuum` to act on them."

**Check F — Version**
Read `shmorch/VERSION` and `~/.claude/skills/shmorch/VERSION`.
- Skill newer → "Shmorch update available ([project version] → [skill version]). Run `/shmorch update`."
- Same → no mention.

**Output format:**

Print a short "What to do next" block after the table. One or two suggestions max — pick the most actionable. Don't list every check result; only surface what's actually relevant. Example:

```
What to do next:
  → You have an active task: "Add OAuth login". Run /shmorch go to resume.
  → Shmorch update available (20260301 → 20260401). Run /shmorch update.
```

If everything looks clean and ready, just say: `→ Run /shmorch go to start a session.`
