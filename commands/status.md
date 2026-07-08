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
   # Open backlog items
   grep -c "^\- \[ \]" docs/state/plan.md 2>/dev/null

   # Closed/done items
   grep -c "^\- \[x\]" docs/state/plan.md 2>/dev/null

   # Acceptance criteria: red (unchecked MVP items, excluding Post-MVP section)
   # Count [ ] items before the Post-MVP heading
   awk '/^## Post-MVP/{exit} /^\- \[ \]/{count++} END{print count+0}' docs/state/acceptance.md 2>/dev/null || echo "?"

   # Acceptance criteria: green (checked MVP items, excluding Post-MVP section)
   awk '/^## Post-MVP/{exit} /^\- \[x\]/{count++} END{print count+0}' docs/state/acceptance.md 2>/dev/null || echo "?"

   # Next 5 open backlog items (active section only)
   grep "^\- \[ \]" docs/state/plan.md 2>/dev/null | head -5 | sed 's/^- \[ \] \*\*\([^*]*\)\*\*.*/  · \1/'

   # Recent commits
   git log --oneline -5 2>/dev/null

   # Current branch
   git branch --show-current 2>/dev/null

   # Test counts — look for the most recent passing summary in session.md
   grep -E "[0-9]+ (tests|unit|api) GREEN" docs/state/session.md 2>/dev/null | head -3
   ```

3. **Count timelog session starts from the project timelog:**
   ```bash
   bash $SHMORCH_HOME/tools/timelog.sh "STATUS_CHECK" "status command run" 2>/dev/null || true
   grep -c "SESSION_START" docs/state/timelog.md 2>/dev/null || echo "?"
   ```

4. **Format output** — adapt to what data exists. Target: fits in 35 lines. Example shape:

   ```
   ── darkbadge status ────────────────────────────────────────
   Sprint        Day 11 of 14  (proof-sprint)
   Branch        main
   Sessions      23 logged

   Acceptance    🔴 18 red · ✅ 14 green  (MVP criteria)
   Next up       Deploy to Vercel + Lambda

   Backlog       64 open · 4 done
   Next 5 open:
     · Overlay column width
     · Dimension ordering
     · Badge dimension clarity
     · Tile sorting
     · Publisher / developer field

   Tests         60 unit GREEN · 24 API GREEN  (as of last session)

   Recent commits
     75fd6ee  chore(shmorch): auto-update VERSION
     946ff17  chore: add commented ignore candidates
     39e4ee6  chore(api): split google-play-scraper imports
   ────────────────────────────────────────────────────────────
   ```

   - **Always show the AC red/green line** — if `docs/state/acceptance.md` doesn't exist, print a warning: `⚠️  No acceptance.md — run /shmorch spec to create one`
   - If all MVP AC items are green: print `🚢 All MVP criteria green — ready to ship?`
   - Omit any other line where data isn't available
   - For test counts: pull from the last session summary if `make test` isn't run live — note "(as of last session)"

5. **Surface one risk or next-step recommendation** after the table — 1 sentence max.

## Variants

- `/shmorch status` — full snapshot (default)
- `/shmorch status tests` — run `make test` live and include fresh counts (warn if slow)
