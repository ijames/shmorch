# Workflow: wrap

Close the current session — stamp the end time, summarize what happened, and update all state files.

## When to use
- When done working for now (end of session)
- After a commit, before leaving the project
- Any time session state needs to be persisted

## Inputs
- None — reads from standard state files

## Roles
- None — runs inline (self-improve step may spawn a researcher agent)

---

## Step 1 — Read current state

Read these files in parallel:
- `docs/state/session.md`
- `docs/state/plan.md`
- `docs/state/timelog.md`
- `docs/development/decisions.md`

---

## Step 2 — Gather recent activity

Run `git log --oneline -20` to see recent commits. Identify which commits happened since the last session entry in session.md (compare dates).

---

## Step 3 — Ask the user ONE question

Ask: "What was the focus of this session? Any decisions worth recording?"

Wait for their response before continuing.

---

## Step 4 — Update timelog

Stamp session end:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_END" "brief summary from user"
```

If there's no SESSION_START for today, stamp that first:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_START" "topic"
bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_END" "summary"
```

---

## Step 5 — Update session.md

First, check if `## Latest Session — YYYY-MM-DD` for today's date already exists in session.md.

- **If it does:** update it in-place — append to the "What was done" and "Commits" sections, and add a note "(continued from earlier context window)". Do NOT create a second same-day entry.
- **If it doesn't:** add a new session entry at the top (below `# Session Log`, above any existing `## Latest Session`).

```markdown
## Latest Session — YYYY-MM-DD

**Branch:** `current-branch`

**What was done:**
- bullet points from git log + user context

**Commits:**
- `hash` message

**State at end of session:**
- Active track status
- Backlog changes if any

**Next up — blockers:**
- (max 2 items; things that block the next build if not done first)

**Next up — plans:**
- (everything else; context, follow-ons, pending decisions)
```

Demote the previous "Latest Session" heading to just a date heading (`## YYYY-MM-DD`).

---

## Step 6 — Update plan.md (if needed)

Check if any track statuses changed. If so, update the Active Tracks table and Backlog. If nothing changed, skip.

---

## Step 6.5 — Graduate closed tracks

Scan `docs/state/tracks/` for any track directory containing a file with `Status: Closed` or `Status: Done`.

```bash
grep -rl "Status: Closed\|Status: Done" docs/state/tracks/ 2>/dev/null
```

For each match found, prompt:
> "Track `<name>` is closed — graduate its findings to docs/ now? (yes / defer)"

If yes: read the track's `→ destination` header and confirm the knowledge has landed in the target doc. If not, do it now. Then run `/shmorch documentarian` to verify.
If defer: note in session.md under "Next up — plans".

---

## Step 6.6 — Clear stale spec.md

Check `docs/state/spec.md`. If it references a track, check whether that track is still active.

```bash
grep -i "track\|Status" docs/state/spec.md 2>/dev/null | head -5
```

If the referenced track is closed, or if no active track exists, replace `docs/state/spec.md` with:

```markdown
# Active Spec

No active spec. See plan.md for next candidates.
```

---

## Step 7 — Update decisions.md (if needed)

If the user mentioned architectural decisions in Step 3, append them:

```markdown
### [YYYY-MM-DD] Decision title
**Context:** Why this needed deciding
**Decision:** What was decided
**Rationale:** Why
```

If no decisions, skip.

---

## Step 8 — Show duration

```bash
bash ~/.claude/skills/shmorch/tools/duration.sh today
```

Show the output to the user.

---

## Step 8.4 — Update CLAUDE.md current state

Update the "Current State" section in `CLAUDE.md` (project root):
- Today's date
- Current integration branch (usually `dev`)
- Current passing test count (from the last test run this session, or check `docs/state/plan.md` for the last recorded count)

Three fields; do it inline without asking.

---

## Step 8.5 — Commit state files

After updating session.md, plan.md, decisions.md, and timelog.md, commit them so the working tree is clean at next session start.

```bash
bash ~/.claude/skills/shmorch/tools/commit-session-state.sh
```

Skip silently if output is "Nothing to commit."

---

## Step 8.6 — Developer prompts

Ask the developer these two questions (one message, expect a brief reply or "nothing"):

> - **Spillover** — anything touched this session that implicates other domains not yet tracked?
> - **Emerging intent** — anything half-formed that deserves a brainstorm file before it's forgotten?

Integrate any answers immediately into the appropriate state file (`plan.md`, `decisions.md`, or a new brainstorm file). Re-commit state files if anything changed (reuse Step 8.5 procedure).

*(To add or remove dimensions, edit Step 8.6 in `~/.claude/skills/shmorch/workflows/wrap.md` or override in `.shmorch/workflows/wrap.md`.)*

---

## Step 8.7 — Update user profile memory

Review the conversation since session start and look for behavioral signal about the developer:

- **What did they dig into?** Topics they asked follow-up questions on, went deeper unprompted, or reframed entirely.
- **What did they wave off?** Things they explicitly deferred, said "don't worry about that," or skipped past.
- **Cognitive moves?** Reframes, mechanism questions, system-level leaps, positioning instincts.
- **Work context signals?** Anything that reveals priorities, constraints, energy, or learning goals.

Then open `~/.claude/projects/<project-slug>/memory/user_profile.md` (create it if it doesn't exist using the standard memory frontmatter format) and add or update observations. Be specific — "asked about SSE vs HTMX to verify they were different abstractions" is more useful than "curious about protocols."

If nothing new was observed this session, skip without comment.

---

## Step 9 — Self-improve (automatic)

Run self-improve at the end of every session. It checks for evidence first — if there's not enough data it exits in seconds.

Read `commands/self-improve.md` and execute it.

If there are no proposals, skip without comment. If there are proposals, present them before closing.

After self-improve completes (or skips), say:

> "Session closed. Run `./shmorch.sh` next time for full agent support."

Only show the shmorch.sh reminder if the env check in Step 1 of session start flagged `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` as not set.
