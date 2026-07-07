# Workflow: sprinter

Manage the active sprint. Reads and updates `docs/state/sprint.md`.

## When to use
- `status` (or no sub-command): check current sprint health and flag risks
- `new`: start a new sprint
- `close`: close the current sprint and archive to docs/state/schedule/

## Inputs
- `docs/state/sprint.md` — active sprint (must exist for status/close)
- `docs/state/plan.md` — backlog reference (for new and close)
- `docs/state/context.md` — project stage (affects risk interpretation)

## Roles
- `agents/roles/sprinter.md` (used for status sub-command)

## Variants
- `new` — start a new sprint
- `close` — close the current sprint and archive to docs/state/schedule/
- `status` (or empty) — show current sprint state, flag risks

---

Sprint docs are intentionally terse — they reference tracks for detail. The sprint records what's in scope and what changed; the tracks record how the work went.

---

## sprinter status (default)

1. Read `docs/state/sprint.md` and `docs/state/context.md` in parallel. Note the project `stage` — it changes what "at risk" means:
   - `R&D`: daily shape changes are normal, not risk signals
   - `proof-sprint`: undecided tech after Day 2 is a risk; missing Gherkin before code is a risk
   - `productionization`/`maintenance`: any missing coverage or unsettled docs is a risk
   If `stage` is missing, treat as `proof-sprint` and note the gap.
   If sprint doesn't exist, tell the user no sprint is active and offer `/shmorch sprinter new`.

2. Call Task:
   ```
   Task(
     description: "Sprinter: sprint status review",
     prompt: |
       ## Role
       Read your role: check `.shmorch/agents/roles/sprinter.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/sprinter.md` (skill default). Act according to the role definition found.

       ## Task
       Read docs/state/sprint.md to get the sprint goal, dates, and scope table.

       For each track in scope, read its current state from docs/state/tracks/<track-slug>/
       (index.md or plan.md — whatever exists). Do not read track files for ~~struck-through~~ rows;
       those are dropped from scope.

       Assess:
       - Which tracks are DONE, IN PROGRESS, NOT STARTED?
       - Which are at risk (blocked, behind, or scope-crept since last status)?
       - Anything needing a developer decision before work can continue?
       - Is the sprint goal achievable in the remaining time?

       ## Output
       Write your assessment to: docs/state/sprint-status.md

       Keep it short — this is a status, not a report.

       Structure:
       ### Sprint: <goal>
       **<start> → <end>** | <days remaining> days left
       **Overall:** On track / At risk / Off track

       | Track | Status | Risk |
       |---|---|---|

       ### Needs attention
       <only if something requires developer input — otherwise omit this section>

       ## Return
       DONE: docs/state/sprint-status.md | <one-line overall status> [| BLOCKER if critical]
   )
   ```

3. Gate: verify `docs/state/sprint-status.md` exists. If BLOCKER, surface immediately.

4. Show the status. Ask: "Anything to adjust?"

---

## sprinter new

1. Ask one at a time:
   - "Sprint goal? (one sentence)"
   - "Start and end dates?"
   - "Which tracks from the backlog are in scope?" (show plan.md backlog briefly)
   - "Definition of done for this sprint specifically?"

2. Write `docs/state/sprint.md` using the sprint template format:

```markdown
# Sprint: <goal>

**<start> → <end>** | Status: Active

## Scope

| Track | Priority | Status | Ref |
|---|---|---|---|
| [<track>](../../state/tracks/<track-slug>/) | High/Med/Low | Not started | |

## Changelog

## Goal Definition of Done
<what the developer said>
```

   Tracks link to their own state directories for detail. Do not copy track content into the sprint doc.

3. Stamp: `bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "sprint started: <goal>"`

4. Confirm with user. Say: "Sprint is live. Use `/shmorch sprinter` to check status anytime."

---

## sprinter close

1. Read `docs/state/sprint.md` and `docs/state/plan.md`.

2. Update the sprint doc before archiving:
   - Set Status to `Closed`
   - Update each track row's Status column to reflect actual outcome (Done / Deferred / Dropped)
   - For any track that was removed during the sprint, ensure its row is `~~struck through~~` with a changelog entry explaining why
   - Add a final changelog entry: `<date>: Sprint closed`

3. Ask: "Anything to add to the changelog before I archive this?"
   Incorporate their answer as a final changelog entry.

4. Archive: copy `docs/state/sprint.md` to `docs/state/schedule/sprint-<start-date>.md`.

5. Update `docs/state/schedule/README.md` — append a row to the Sprints table:
   ```
   | [Sprint: <goal>](sprint-<start-date>.md) | <start> → <end> | <one-line outcome> |
   ```

6. Delete `docs/state/sprint.md` (after confirming with user).

7. Update `docs/state/plan.md`: mark any completed tracks DONE, move deferred tracks back to backlog with a note.

8. Stamp: `bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "sprint closed: <goal>"`

9. Ask: "New sprint, prioritize backlog, or take a break?"

---

## Scope changes mid-sprint

When a track is added or dropped during an active sprint (outside of `sprinter new` or `sprinter close`), update `docs/state/sprint.md` directly:

- **Drop a track:** Strike through its row with `~~track name~~`, add a Changelog entry: `YYYY-MM-DD: Dropped <track> — <reason>`
- **Add a track:** Add a new row, add a Changelog entry: `YYYY-MM-DD: Added <track> — <reason>`

Never silently delete scope — the changelog is the audit trail.
