# Command: status

Print a concise project health snapshot — sprint progress, task state, backlog depth, recent commits, and test counts where available.

## When to run
- Any time the user wants a quick "where are we?" without reading full state files
- Before a session to get oriented fast
- After a burst of work to see what changed

## Steps

1. **Read state files in parallel:**
   - `docs/state/plan.md` — current task + backlog count
   - `docs/state/session.md` — last session summary (first 40 lines)
   - `docs/state/context.md` — project name, stage, sprint target

2. **Collect metrics from shell (run in parallel):**
   ```bash
   # Sprint day — count SESSION_START events in timelog
   grep -c "SESSION_START" ~/.claude/skills/shmorch/tools/../../../projects/$(pwd | sed 's|/|-|g')/timelog.log 2>/dev/null || grep -c "SESSION_START" docs/state/timelog.log 2>/dev/null || echo "?"

   # Open backlog items
   grep -c "^\- \[ \]" docs/state/plan.md 2>/dev/null

   # Closed/done items
   grep -c "^\- \[x\]" docs/state/plan.md 2>/dev/null

   # Recent commits
   git log --oneline -5 2>/dev/null

   # Current branch
   git branch --show-current 2>/dev/null

   # Test counts — look for the most recent passing summary in session.md
   grep -E "[0-9]+ (tests|unit|api) GREEN" docs/state/session.md 2>/dev/null | head -3
   ```

3. **Count timelog session starts from the project timelog:**
   ```bash
   bash ~/.claude/skills/shmorch/tools/timelog.sh "STATUS_CHECK" "status command run" 2>/dev/null || true
   grep -c "SESSION_START" docs/state/timelog.log 2>/dev/null || echo "?"
   ```

4. **Format output** — adapt to what data exists. Target: fits in 25 lines. Example shape:

   ```
   ── darkbadge status ────────────────────────────────────────
   Sprint        Day 11 of 14 (proof-sprint)
   Branch        feature/20260517-web-combo-search-ingest
   
   Current task  Unknown slug route + unscored tile auto-ingest ✓ DONE
   Next up       Deploy to Vercel + Lambda
   
   Backlog       12 open · 6 done
   Blockers      Design tooling decision ⚠️
   
   Tests         60 unit GREEN · 24 API GREEN · 1 skipped
   
   Recent commits
     7a81855  chore(backlog): add 5 product design items
     6679396  fix(sse): catch all exceptions in stream_ingest
     9b6bf7a  fix(overlay): don't call history.back() on no pushState
   ────────────────────────────────────────────────────────────
   ```

   Omit any line where data isn't available. For test counts: pull from the last session summary if a live `make test` isn't run — note the source ("as of last session").

5. **Surface one risk or next-step recommendation** after the table — 1 sentence max.

## Variants

- `/shmorch status` — full snapshot (default)
- `/shmorch status tests` — run `make test` live and include fresh counts (warn if slow)
