# Workflow: orient

The orientation phase — read state, surface gaps, propose the next move. Runs after
provisioning (or directly, when the repo is already current). Invoked by
`workflows/go.md`; not a user command.

## Inputs
- Optional topic/detail (passed through from `go`, used as timelog detail)
- Standard state files: `docs/state/context.md`, `docs/state/stack.md`, `docs/state/session.md`, `docs/state/plan.md`

## Roles
- None — runs inline

## Orientation is shallow — no code until a directive

Read **only** `docs/state/*` (context, stack, session, plan) and git status/log metadata. Do **not** open, read, `grep`, or analyze source code, and do **not** spawn discovery/analyst agents, during orientation. Reading code is the Analyze / Build phase (or `discover`) — it begins only after the user answers your proposal with a directive. If a good next move needs code investigation, *offer* it ("want me to analyze X?") instead of doing it now.

---

## Step 0 — Pulse check

If `docs/state/index.md` exists, read it first — the front-matter `summary` lines (see
`core/documentation.md` § Front-Matter Previews) give a cheap overview of what's changed
before opening the full files in Steps 1–3. If it's missing, skip straight to Step 1 (older
projects may not have it yet — not an error).

---

## Step 1 — Read context and stack

Read `docs/state/context.md` and `docs/state/stack.md` in parallel.

If `stack.md` is missing or empty, note it: "Stack inventory hasn't been filled in yet — I'll build it up as we work, or you can run `/shmorch vacuum` to kick off a stack analysis."

If `context.md` is unfilled, run the Context Setup flow:
1. "Before we start, a few quick questions."
2. Ask ONE at a time:
   - "What is this project? One or two sentences."
   - "What's your tech stack? ('not sure yet' is fine)"
   - "Existing codebase or starting fresh?"
   - "PR merge strategy: merge, squash, or rebase? (merge preserves branch topology in git graph; squash = one commit per PR; rebase = linear history, no merge commits)"
   - "Enable the docs-placement reminder right after each docs file is written? (flags possible wrong skeleton location while it's fresh, not batched at session end — off by default)"
   - "Anything I should never do without asking first?"
3. Write answers to `docs/state/context.md`, the merge strategy to `.shmorch/AGENTS.md` under Branching Discipline, and the docs-placement choice to `.shmorch/AGENTS.md` under Docs Placement Hook `**Status:**`, confirm with user.

If filled, summarize in 1-2 sentences.

---

## Step 2 — Read last session

Read `docs/state/session.md`. Summarize what happened last time in 1-2 sentences.

---

## Step 3 — Read plan

Read `docs/state/plan.md`. Show the active tracks table and current focus.

---

## Step 4 — Check for leftover work

Run `git status` and `git log --oneline -5` in parallel. Then:

1. If there are uncommitted changes, mention it upfront:
   > "There are uncommitted changes from last time — want to commit those first, or continue and commit later?"
   If the working tree is clean, skip this without comment.

2. Compare `git log --oneline -5` against the "Commits" list in session.md. If the recent commits already match what session.md records as done last session, note this internally and skip re-committing those items. This prevents duplicate commits after context window splits.

---

## Step 5 — Untracked test failures check

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

## Step 6 — Memory staleness check

Scan the CLI's external memory for this project (e.g. Claude `~/.claude/projects/.../memory/`, omp `memory://`) for any entries containing `UNFIXED`, `OPEN QUESTION`, `TWO BUGS`, or `BUG` (case-insensitive). For each match found:

1. Note what the memory claims
2. Run `git log --oneline -10` and `git grep` to check if the claim is still current
3. If evidence suggests the memory is stale, update or remove it before relying on it

Skip silently if no matches found. Do not surface this step to the user unless a stale memory is found — in that case, note the correction briefly.

Pattern that triggered this rule: a session consumed a full task cycle verifying a bug that memory marked "UNFIXED" but git log showed was already fixed two sessions earlier.

---

## Step 7 — Surface gaps and propose next move

Before asking what to work on, scan for obvious gaps and surface them:
- Are there unfilled placeholders in `context.md` (code style, test framework, commit style)?
- Is `stack.md` missing key dependency versions?
- Does `session.md` note specific things to pick up immediately?

If the session.md has a "Pick up immediately" note, lead with that — do it or propose it before asking the open-ended question.

Then propose 2-3 concrete options for what to do next, based on the plan and any gaps found. Don't just ask "what do you want to work on?" cold — give the user something to react to.

If the user declines all options or says "not yet", ask what's holding them back, or offer something smaller (a quick scan, filling in state, answering a codebase question). Never just go quiet.

---

## Working with Tracks

Active tracks live in `docs/state/tracks/`. Each has index.md, spec.md, plan.md.

When starting work on a track:
1. Read the track's spec and plan
2. Stamp: `bash "$SHMORCH_HOME/tools/timelog.sh" "TASK_START" "track name"`
3. Update `docs/state/plan.md` status to "In progress"
4. Do the work
5. Stamp: `bash "$SHMORCH_HOME/tools/timelog.sh" "TASK_DONE" "track name"`

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
Resolution order: `.shmorch/workflows/<name>.md` (project override) → `$SHMORCH_HOME/workflows/<name>.md` (skill default).

## When work is done for the day

Suggest this sequence naturally — don't wait for the user to ask:

1. **Vacuum** — `/shmorch vacuum` to catch TODOs, dead code, empty tests before committing
2. **Commit** — `/shmorch commit` to group and commit changes cleanly
3. **Wrap** — `/shmorch wrap` to close the session and update state

You don't have to do all three every time. After a small change, commit + wrap is enough. After a big build, vacuum first.

## Stack Awareness

Before recommending any package, upgrade, pattern, or API:
1. Check `docs/state/stack.md` — is there a version constraint that rules this out?
2. If the stack has external constraints (hosting platform, client environment, API compatibility), respect them without asking the user to re-explain them every session
3. If you discover a new constraint during work (e.g. a package can't be upgraded because of a transitive dependency), add it to `stack.md` immediately
4. The "Upgrade Opportunities" section in `stack.md` is where good ideas go when they can't be acted on yet — log them there, not as inline TODOs

## Architecture Decisions

When a significant decision is made, append to `docs/development/decisions.md`:

```markdown
### [YYYY-MM-DD] Decision title
**Context:** Why this needed deciding
**Decision:** What was decided
**Rationale:** Why
```

Identity, timing events, and safety rules are always loaded from `shmorch-core.md` — not repeated here.
