# Workflow: go

Orient, read state, and propose the next move at the start of a session.

## When to use
- At the start of every session (auto-runs via `commands/go.md`)
- After resuming an interrupted session
- Any time you need to re-orient mid-session

## Inputs
- Optional topic/detail from `$ARGUMENTS` (used as timelog detail)
- Standard state files: `docs/state/context.md`, `docs/state/stack.md`, `docs/state/session.md`, `docs/state/plan.md`

## Roles
- None — runs inline

---

## Step 1 — Stamp session start

Check session state:

```bash
bash ~/.claude/skills/shmorch/tools/check-session-state.sh
```

- `CLEAN` (or script missing / no timelog yet): stamp SESSION_START normally.
- `INTERRUPTED`: previous session has no SESSION_END — run the **Catch-Up Wrap** protocol below before opening the new session.

Use the remainder of `$ARGUMENTS` after "go" as the detail. If empty, use "new session".

---

### Catch-Up Wrap (runs only on INTERRUPTED)

Tell the user immediately, before doing anything else:

> "Previous session wasn't wrapped — running catch-up wrap now before we start."

Then execute these steps in order:

**CW-1 — Close the previous session in the timelog:**
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_END" "auto-wrapped on reentry"
```

**CW-2 — Infer what happened:**
```bash
git log --oneline -10
```
Read `docs/state/session.md` to find the last session entry date. Commits since that date are what the previous session produced.

**CW-3 — Update session.md:**
Write a session entry (or update today's if one exists) using the standard session.md format from `workflows/wrap.md` Step 5. Use git log as the source for "What was done" and "Commits". Set the focus line to "Session ended without wrap — reconstructed from git log." Demote the previous "Latest Session" heading to a date heading.

**CW-4 — Update plan.md:**
Check if any tracks or tasks visible in git commits have a status that should now be updated. Apply changes if obvious; skip if unclear.

**CW-5 — Graduate closed tracks:**
```bash
grep -rl "Status: Closed\|Status: Done" docs/state/tracks/ 2>/dev/null
```
For each match, prompt the user: "Track `<name>` is closed — graduate now or defer?" (one question, non-blocking).

**CW-6 — Commit state files:**
```bash
bash ~/.claude/skills/shmorch/tools/commit-session-state.sh
```
Skip silently if nothing to commit.

**CW-7 — Stamp new session start:**
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_START" "DETAIL"
```

Tell the user: "Catch-up wrap done. Continuing with session start."

Then extract and surface the first **BLOCKER** from session.md:
```bash
grep -A1 "BLOCKER\|Pick up immediately" docs/state/session.md | head -4
```

Then continue with Step 1b below.

---

## Step 1b — Auto-update check

If `SHMORCH_SELF=1` is set in the environment, skip this step entirely — the skill repo is its own source of truth.

```bash
PROJECT_VERSION=$(cat .shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
SKILL_VERSION=$(cat ~/.claude/skills/shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
echo "Project: $PROJECT_VERSION  Skill: $SKILL_VERSION"
```

- If versions match or skill file missing: skip silently.
- If skill version is newer: say exactly this:
  > "Shmorch update available ($PROJECT_VERSION → $SKILL_VERSION). Run now before we start? (yes/no)"
  - **yes**: read `commands/auto-update.md` and run it, then continue go from Step 2.
  - **no**: continue go, remind at wrap.

---

## Step 2 — Read context and stack

Read `docs/state/context.md` and `docs/state/stack.md` in parallel.

If `stack.md` is missing or empty, note it: "Stack inventory hasn't been filled in yet — I'll build it up as we work, or you can run `/shmorch vacuum` to kick off a stack analysis."

If `context.md` is unfilled, run the Context Setup flow:
1. "Before we start, a few quick questions."
2. Ask ONE at a time:
   - "What is this project? One or two sentences."
   - "What's your tech stack? ('not sure yet' is fine)"
   - "Existing codebase or starting fresh?"
   - "PR merge strategy: merge, squash, or rebase? (merge preserves branch topology in git graph; squash = one commit per PR; rebase = linear history, no merge commits)"
   - "Anything I should never do without asking first?"
3. Write answers to `docs/state/context.md` and the merge strategy to `.shmorch/CLAUDE.md` under Branching Discipline, confirm with user.

If filled, summarize in 1-2 sentences.

---

## Step 3 — Read last session

Read `docs/state/session.md`. Summarize what happened last time in 1-2 sentences.

---

## Step 4 — Read plan

Read `docs/state/plan.md`. Show the active tracks table and current focus.

---

## Step 5 — Check for leftover work

Run `git status` and `git log --oneline -5` in parallel. Then:

1. If there are uncommitted changes, mention it upfront:
   > "There are uncommitted changes from last time — want to commit those first, or continue and commit later?"
   If the working tree is clean, skip this without comment.

2. Compare `git log --oneline -5` against the "Commits" list in session.md. If the recent commits already match what session.md records as done last session, note this internally and skip re-committing those items. This prevents duplicate commits after context window splits.

---

## Step 5b — Untracked test failures check

Scan `docs/state/session.md` for lines containing `failing`, `outstanding`, `pre-existing`, or `test failure` (case-insensitive):

```bash
grep -i "failing\|outstanding\|pre-existing\|test failure" docs/state/session.md | head -10
```

For each failure cluster found:
1. Check `docs/state/plan.md` — is there already a backlog item tracking it?
2. If **no plan item exists**: add one immediately to the Backlog section of `plan.md`:
   ```
   - [ ] Fix pre-existing test failures: <component/area> (<N> failures) — tracked <YYYY-MM-DD>
   ```
3. Surface to the user briefly: "Found <N> pre-existing test failures in <area> with no plan item. Added to backlog."

Do not surface this step unless failures are found. A failure with no plan item is invisible to sprint planning and violates the always-red rule.

---

## Step 5c — Memory staleness check

Scan the project memory directory (`~/.claude/projects/.../memory/`) for any files containing the strings `UNFIXED`, `OPEN QUESTION`, `TWO BUGS`, or `BUG` (case-insensitive). For each match found:

1. Note what the memory claims
2. Run `git log --oneline -10` and `git grep` to check if the claim is still current
3. If evidence suggests the memory is stale, update or remove it before relying on it

Skip silently if no matches found. Do not surface this step to the user unless a stale memory is found — in that case, note the correction briefly.

Pattern that triggered this rule: a session consumed a full task cycle verifying a bug that memory marked "UNFIXED" but git log showed was already fixed two sessions earlier.

---

## Step 6 — Surface gaps and propose next move

Before asking what to work on, scan for obvious gaps and surface them:
- Are there unfilled placeholders in `context.md` (code style, test framework, commit style)?
- Is `stack.md` missing key dependency versions?
- Does `session.md` note specific things to pick up immediately?

If the session.md has a "Pick up immediately" note, lead with that — do it or propose it before asking the open-ended question.

Then propose 2-3 concrete options for what to do next, based on the plan and any gaps found. Don't just ask "what do you want to work on?" cold — give the user something to react to.

If the user declines all options or says "not yet", ask what's holding them back, or offer something smaller (a quick scan, filling in state, answering a codebase question). Never just go quiet.

---

## Identity while in Shmorch mode

- Active development lead, not a passive assistant
- One question at a time — never a barrage
- Plans before code. Specs before plans.
- Ruthless about cruft: dead code, stale docs, duplicate tests
- Never switch branches without asking

## Working with Tracks

Active tracks live in `docs/state/tracks/`. Each has index.md, spec.md, plan.md.

When starting work on a track:
1. Read the track's spec and plan
2. Stamp: `bash ~/.claude/skills/shmorch/tools/timelog.sh "TASK_START" "track name"`
3. Update `docs/state/plan.md` status to "In progress"
4. Do the work
5. Stamp: `bash ~/.claude/skills/shmorch/tools/timelog.sh "TASK_DONE" "track name"`

## Workflow Phases

| Phase | File | When |
|---|---|---|
| Intake | `.shmorch/workflows/intake.md` | New conversation, unclear goal |
| Analyze | `.shmorch/workflows/analyze.md` | Existing code to examine |
| Spec | `.shmorch/workflows/spec.md` | Define what to build |
| Design | `.shmorch/workflows/design.md` | Architecture before code |
| Build | `.shmorch/workflows/build.md` | Time to code |
| Vacuum | `.shmorch/workflows/vacuum.md` | After build or on demand |

Read the workflow file before starting each phase.
Resolution order: `.shmorch/workflows/<name>.md` (project override) → `~/.claude/skills/shmorch/workflows/<name>.md` (skill default).

## When work is done for the day

Suggest this sequence naturally — don't wait for the user to ask:

1. **Vacuum** — `/shmorch vacuum` to catch TODOs, dead code, empty tests before committing
2. **Commit** — `/shmorch commit` to group and commit changes cleanly
3. **Wrap** — `/shmorch wrap` to close the session and update state

You don't have to do all three every time. After a small change, commit + wrap is enough. After a big build, vacuum first.

## Timing — Log Events

Use `bash ~/.claude/skills/shmorch/tools/timelog.sh "EVENT" "detail"` at transitions:

| When | Event | Detail |
|---|---|---|
| Session opens | `SESSION_START` | topic |
| Task begins | `TASK_START` | task name |
| Phase changes | `PHASE` | e.g. "intake → spec" |
| Task completes | `TASK_DONE` | task name |
| Decision made | `DECISION` | brief description |
| Session closes | `SESSION_END` | one-line summary |

Run `bash ~/.claude/skills/shmorch/tools/duration.sh today` anytime to see elapsed times.

## Architecture Decisions

When a significant decision is made, append to `docs/development/decisions.md`:

```markdown
### [YYYY-MM-DD] Decision title
**Context:** Why this needed deciding
**Decision:** What was decided
**Rationale:** Why
```

## Stack Awareness

Before recommending any package, upgrade, pattern, or API:
1. Check `docs/state/stack.md` — is there a version constraint that rules this out?
2. If the stack has external constraints (hosting platform, client environment, API compatibility), respect them without asking the user to re-explain them every session
3. If you discover a new constraint during work (e.g. a package can't be upgraded because of a transitive dependency), add it to `stack.md` immediately
4. The "Upgrade Opportunities" section in `stack.md` is where good ideas go when they can't be acted on yet — log them there, not as inline TODOs

## Safety Rules

- Never delete without user confirmation
- Never git push without user confirmation
- Never switch branches without asking
- Write `docs/state/plan.md` before multi-file changes
- One question at a time
