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
bash $SHMORCH_HOME/tools/timelog.sh "SESSION_END" "brief summary from user"
```

If there's no SESSION_START for today, stamp that first:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "SESSION_START" "topic"
bash $SHMORCH_HOME/tools/timelog.sh "SESSION_END" "summary"
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

Scan `docs/state/tracks/` for tracks marked Closed, Done, or Complete:

```bash
grep -rl "Status: Closed\|Status: Done\|Status: Complete" docs/state/tracks/ 2>/dev/null
```

For each match, read the track's `→ destination` line. Then check whether the destination file was touched after the track was opened:

```bash
# Replace <opened-date> with the track's Opened: field (YYYY-MM-DD) and <dest> with the destination path
git log --oneline --since="<opened-date>" -- <dest> 2>/dev/null | head -3
```

- **No commits found on destination file since track opened** → knowledge has not landed. Prompt: "Track `<name>` is complete but knowledge not yet in `<dest>` — graduate now? (yes / defer)"
- **Commits found** → assume graduated; skip silently.

If yes: read the track's index.md, extract the key findings, write them to the destination doc. Then run `/shmorch documentarian` to verify.
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
bash $SHMORCH_HOME/tools/duration.sh today
```

Show the output to the user.

---

## Step 8.4 — Update Current State

Update (or add) a "Current State" section in `.shmorch/AGENTS.md` — the shared project-instructions file both Claude Code and omp load (via their respective import chains):
- Today's date
- Current integration branch (usually `dev`)
- Current passing test count (from the last test run this session, or check `docs/state/plan.md` for the last recorded count)

Three fields; do it inline without asking.

---

## Step 8.45 — Patch doc sibling navigation

Run docs-nav to keep sibling links current in every docs/ directory:

```bash
bash $SHMORCH_HOME/tools/docs-nav.sh docs/
```

If `docs/` does not exist in the project, skip silently. If any files were patched, stage them as part of the state commit in Step 8.5 — do not create a separate commit.

---

## Step 8.5 — Commit state files

After updating session.md, plan.md, decisions.md, and timelog.md, commit them so the working tree is clean at next session start.

```bash
bash $SHMORCH_HOME/tools/commit-session-state.sh
```

Skip silently if output is "Nothing to commit."

---

## Step 8.55 — Branch close-out prompt

Check the current branch:

```bash
git branch --show-current
```

If on `main` or `dev`: skip silently.

If on any other branch (feature, fix, docs, etc.):

1. Check whether the branch has unpushed commits:
   ```bash
   git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline HEAD
   ```

2. Ask in ONE message (not separately):
   > "You're on `<branch>`. Want to (a) push + open a PR now, and (b) return to main after?"

3. If yes to push + PR:
   ```bash
   git push -u origin <branch>
   gh pr create --title "<conventional-commit title>" --body "$(cat <<'EOF'
   ## Summary
   <bullet points from session>

   ## Test plan
   - [ ] CI passes

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

4. If yes to return to main:
   ```bash
   git checkout main && git pull origin main
   ```

5. If no to either: note in session.md under "Next up — plans": "Push `<branch>`, open PR, return to main."

---

## Step 8.6 — Developer prompts

Read wrap prompts from two sources (both may exist):
1. `$SHMORCH_HOME/wrap-prompts.md` — skill defaults (always read)
2. `.shmorch/wrap-prompts.md` — project additions (read if present, appended after defaults)

Ask all prompts together in one message. Expect a brief reply or "nothing" per item.

Integrate any answers immediately into the appropriate state file (`plan.md`, `decisions.md`, or a new brainstorm file). Re-commit state files if anything changed (reuse Step 8.5 procedure).

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
