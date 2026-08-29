---
loads_when: re-ranking the backlog, surfacing effort/value tradeoffs
size: 138 lines
---

# Workflow: prioritize

Re-rank the backlog and surface effort/value tradeoffs. Updates `docs/project/plan/` only after developer confirmation.

## When to use
- Before starting a new sprint
- When the backlog has grown and priorities are unclear
- After a significant change in project goals or constraints

## Inputs
- `docs/project/plan/` — current backlog and track statuses
- `docs/project/tracks/*/index.md` — actual track status (source of truth, may have drifted from plan/ frontmatter)
- `git branch -a` — in-flight work (a branch with no matching plan/track entry, or a track marked Open with no branch and no recent commits, is a reconciliation finding)
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
tail -1 docs/project/timelog.md
```
Confirm the tail line actually shows `PHASE | prioritize: starting` — don't fire-and-forget
the `timelog.sh` call. If it's missing, the stamp didn't land; re-run before continuing.

### Step 2 — Read current state

Read in parallel:
- `docs/project/plan/` — current backlog and track statuses
- `docs/project/tracks/*/index.md` — actual status per track (`status:` frontmatter)
- `docs/project/sprint.md` — active sprint scope (if exists)
- `docs/{product,technology}/decisions/ (topic-appropriate)` — architectural constraints that affect priority

```bash
git branch -a
```
Pass this list to the Task below so it can spot branches with no matching plan/track entry
(untracked work) and tracks marked Open with no matching branch (stalled).

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

    Reconcile plan/ against reality before scoring:
    - Read `docs/project/tracks/*/index.md` `status:` frontmatter. Where a plan item links to a
      track, the track's status is the source of truth — a plan item still marked open whose
      track is Closed is DROPPED (already done), not ranked.
    - Cross-check against the `git branch -a` list provided above. A branch with no matching
      plan/track entry is untracked in-flight work — surface it, don't score it (someone needs
      to file it before it can be ranked). A track marked Open with no matching branch is
      stalled — flag it, don't just rank it as if work were progressing.
    - A track that already has an active branch with commits needs less remaining effort than
      the plan item's original estimate suggests — adjust Effort down accordingly and say why.

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

    ### Reconciliation
    <mismatches found while cross-checking plan/ vs tracks/ vs git branches: plan status
    contradicted by track status, tracks with no branch, branches with no plan/track entry>

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

**Gate — do not end this workflow until the index row for this run shows one of
`Applied YYYY-MM-DD` / adjusted-then-applied / `Superseded`.** A run that produces a
proposal file but leaves the index row at "Pending decision" has not completed Step 6 —
go back and get the developer's apply/adjust/keep answer before stamping complete.

```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "prioritize: complete"
tail -1 docs/project/timelog.md
```
Confirm the tail line shows `PHASE | prioritize: complete` before ending the workflow —
this stamp has gone missing in practice despite being scripted.
