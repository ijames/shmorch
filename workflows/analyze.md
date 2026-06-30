# Workflow: Analyze

Deep examination of a specific area of the codebase. Use when the user wants to understand something before speccing or designing it.

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## When to use
- Before speccing or designing a feature that touches existing code
- When the user asks "how does X work?" or "where are the seams for Y?"
- Any time a codebase area needs to be understood before acting on it

## Inputs

- Area to analyze (directory, module, or concern — e.g. "src/payments/", "auth flow", "test coverage")
- Question to answer (e.g. "where are the seams for extracting this service?")

If either is unclear, ask one question before proceeding.

## Roles
- `agents/roles/analyst.md` (one per sub-area, run in parallel)

---

## Step 1 — Stamp
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "analyze: starting — <area>"
```

---

## Step 2 — Identify or create the track

Analysis artifacts need a home with a lifecycle. Before scoping:

1. Ask: does a track in `docs/state/tracks/` already cover this area? (`ls docs/state/tracks/` to check)
2. If yes: use it. Set `TRACK_DIR=docs/state/tracks/<existing-slug>/`.
3. If no: create one now. Include `analysis` in the slug.
   ```bash
   mkdir -p docs/state/tracks/<YYYYMMDD>-analysis-<slug>/
   ```
   Write a minimal `docs/state/tracks/<YYYYMMDD>-analysis-<slug>/index.md`:
   ```markdown
   ↑ [Plan](../../plan.md)
   → <destination docs, e.g. decisions.md or plan.md — fill in after analysis>

   # Track: <Title> — Analysis

   **Status:** Investigation
   **Opened:** <YYYYMMDD>
   **Domain:** <Architecture | Feature | Fix | Process>

   ## Why
   <one sentence: what prompted this analysis>

   ## Files

   <!-- updated as analysts complete -->
   - [analysis-summary-<YYYYMMDD>.md](analysis-summary-<YYYYMMDD>.md)

   ## Work log

   ### <YYYYMMDD>
   Analysis initiated.
   ```
   Set `TRACK_DIR=docs/state/tracks/<YYYYMMDD>-analysis-<slug>/`.

Note: if attaching to an existing track that wasn't created by analyze, add an `## Analysis Files` section to its `index.md` rather than renaming the track.

All subsequent output files go under `TRACK_DIR`.

---

## Step 3 — Scope the work

List the files in the target area. Identify up to 4 independent sub-areas that can be analyzed in parallel (e.g. by layer: models, services, routes, tests).

---

## Step 4 — Call Task (parallel analysts)

For each sub-area, call Task. All calls may run in parallel.

```
Task(
  description: "Analyst: <sub-area>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/analyst.md` first (project override); if not present, use `~/.claude/skills/shmorch/agents/roles/analyst.md` (skill default). Act according to the role definition found.

    ## Task
    Analyze <sub-area> with focus on: <question from inputs>.
    - List all files examined
    - Identify key classes, functions, routes, or data structures
    - Note patterns, coupling, or design decisions relevant to the question
    - Flag anything that will affect the answer

    ## Output
    Write your findings to: <TRACK_DIR>/analysis-<sub-area-slug>-<YYYYMMDD>.md

    Structure:
    ### What this area does
    ### Key elements
    ### Relevant to the question
    ### Flags
    - [BLOCKER] <anything that prevents a clean answer>
    - [CRUFT] <dead or stale code found>
    - [GAP] <missing coverage or documentation>

    ## Return
    DONE: <TRACK_DIR>/analysis-<sub-area-slug>-<YYYYMMDD>.md | <one-line finding> [| BLOCKER | CRUFT | GAP]
)
```

Stamp each spawn:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "analyst → <sub-area>"
```

---

## Step 5 — Gate

After all Task calls complete:
- Verify each output file exists. If any is missing, re-run that Task before continuing.
- If any return contains `BLOCKER`: surface it to the user — do not synthesize until resolved.
- Stamp completions:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "analyst → <TRACK_DIR>/analysis-<sub-area>-<date>.md"
```

---

## Step 6 — Synthesize

Read all output files. Write `<TRACK_DIR>/analysis-summary-<YYYYMMDD>.md`:

```markdown
# Analysis: <area> — <date>

## Question
<original question>

## Answer
<direct answer, 2-4 sentences>

## Evidence
<key findings from analyst outputs that support the answer>

## Flags
<consolidated [BLOCKER], [CRUFT], [GAP] items — de-duplicated>

## Next step
<recommended action: Spec / Design / Build / Defer — one sentence>
```

Update the track's `index.md`:
- Add each `analysis-<sub-area-slug>-<YYYYMMDD>.md` file to the `## Files` (or `## Analysis Files`) index, one line per file with a one-phrase description.
- Add a work log entry: `### <date>` + what was analyzed and what the answer was.

---

## Step 7 — Stamp and hand off
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "analyze: complete — <one-line answer>"
```

Present the summary to the user. Propose the next step based on the `## Next step` field.

**Graduation note:** findings in this track are starting points, not destinations. As they resolve:
- Decisions → `docs/development/decisions.md` (or topic split)
- Action items → `plan.md` backlog
- Architecture facts → `docs/architecture/`
- Stale/superseded analysis files → delete, leave a one-line note in the track work log
