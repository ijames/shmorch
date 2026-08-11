---
loads_when: re-ranking the backlog, surfacing effort/value tradeoffs
size: 122 lines
---

# Workflow: prioritize

Re-rank the backlog and surface effort/value tradeoffs. Updates `docs/project/plan/` only after developer confirmation.

## When to use
- Before starting a new sprint
- When the backlog has grown and priorities are unclear
- After a significant change in project goals or constraints

## Inputs
- `docs/project/plan/` — current backlog and track statuses
- `docs/project/sprint.md` — active sprint scope (if exists)
- `docs/{product,technology}/decisions/ (topic-appropriate)` — architectural constraints that affect priority

## Roles
- `agents/roles/prioritizer.md`

## Variants
- `sprint` — prioritize within the current sprint scope only
- (empty) — prioritize full backlog

---

### Step 1 — Stamp
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "prioritize: starting"
```

### Step 2 — Read current state

Read in parallel:
- `docs/project/plan/` — current backlog and track statuses
- `docs/project/sprint.md` — active sprint scope (if exists)
- `docs/{product,technology}/decisions/ (topic-appropriate)` — architectural constraints that affect priority

### Step 3 — Call Task

```
Task(
  description: "Prioritizer: backlog ranking",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/prioritizer.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/prioritizer.md` (skill default). Act according to the role definition found.

    ## Task
    Analyze the backlog in docs/project/plan/.
    Also read docs/{product,technology}/decisions/ (topic-appropriate) for constraints that affect ordering.
    If docs/project/sprint.md exists, note what is already committed to the sprint.

    Produce a re-ranked backlog with scoring rationale for each item.

    Score each track on:
    - Value: impact on the project's core goal (High / Med / Low)
    - Effort: estimated relative effort (S / M / L / XL)
    - Blocking: does anything else depend on this being done first? (Yes / No)
    - Risk: does deferring this accumulate technical or product risk? (High / Med / Low)

    Flag any items that should be DROPPED (no longer relevant) or DEFERRED (valid but not now).

    ## Output
    Ensure the run artifacts directory exists: `mkdir -p docs/project/prioritizer`

    Write your ranked backlog to: docs/project/prioritizer/YYYYMMDD_priority-proposal.md (use today's date)
    **Never write to docs/project/priority-proposal.md at the root level.**

    Use this structure:
    ### Proposed Backlog Order

    | Rank | Track | Value | Effort | Blocking | Risk | Rationale |
    |---|---|---|---|---|---|---|

    ### Drops
    <tracks to remove entirely, with reason>

    ### Defers
    <tracks to defer, with condition for re-evaluation>

    ### Notes
    <anything the developer should know before deciding>

    ## Return
    DONE: docs/project/priority-proposal.md | <one-line summary of top priority> [| BLOCKER if a critical dependency conflict exists]
)
```

### Step 4 — Gate

Verify `docs/project/prioritizer/YYYYMMDD_priority-proposal.md` exists.
If BLOCKER in return: surface the conflict to the developer before showing the proposal.

### Step 5 — Update index and stamp

If `docs/project/prioritizer/index.md` does not exist, create it:
```markdown
# Prioritizer Runs

↑ [docs/project/](../index.md)

Backlog ranking proposals from `/shmorch prioritize` runs.
Files are named `YYYYMMDD_priority-proposal.md`. Applied proposals are kept as historical record.

---

| Date | File | Top priority | Status |
|---|---|---|---|
```

Add a row for this run.

### Step 6 — Present and confirm

Show the proposed ranking to the developer. Ask:

> "Want to apply this order to plan/, adjust anything first, or keep the current order?"

- If apply: add a `priority: <rank>` frontmatter field to each affected file in `docs/project/plan/` to match the proposal (no shared file to rewrite — edit each item independently). Update the index row in `docs/project/prioritizer/index.md` to mark status "Applied YYYY-MM-DD". Keep the proposal file as a historical record.
- If adjust: make the requested changes, re-confirm, then apply.
- If keep: mark the index row "Superseded". No changes to plan/.

```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "prioritize: complete"
```
