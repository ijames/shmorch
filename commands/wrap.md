# Command: wrap

Wrap up the current session — stamp the end time, summarize what happened, and update all state files. Run this when you're done working for now.

All paths are relative to the project root (NOT inside shmorch/).

## Step 1 — Read current state

Read these files in parallel:
- `shmorch/state/session.md`
- `shmorch/state/plan.md`
- `shmorch/state/timelog.md`
- `shmorch/state/decisions.md`

## Step 2 — Gather recent activity

Run `git log --oneline -20` to see recent commits. Identify which commits happened since the last session entry in session.md (compare dates).

## Step 3 — Ask the user ONE question

Ask: "What was the focus of this session? Any decisions worth recording?"

Wait for their response before continuing.

## Step 4 — Update timelog

Stamp session end:
```bash
bash shmorch/tools/timelog.sh "SESSION_END" "brief summary from user"
```

If there's no SESSION_START for today, stamp that first:
```bash
bash shmorch/tools/timelog.sh "SESSION_START" "topic"
bash shmorch/tools/timelog.sh "SESSION_END" "summary"
```

## Step 5 — Update session.md

Add a new session entry at the top (below `# Session Log`, above any existing `## Latest Session`):

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
```

Demote the previous "Latest Session" heading to just a date heading (`## YYYY-MM-DD`).

## Step 6 — Update plan.md (if needed)

Check if any track statuses changed. If so, update the Active Tracks table and Backlog. If nothing changed, skip.

## Step 7 — Update decisions.md (if needed)

If the user mentioned architectural decisions in Step 3, append them:

```markdown
### [YYYY-MM-DD] Decision title
**Context:** Why this needed deciding
**Decision:** What was decided
**Rationale:** Why
```

If no decisions, skip.

## Step 8 — Show duration

```bash
bash shmorch/tools/duration.sh today
```

Show the output to the user.
