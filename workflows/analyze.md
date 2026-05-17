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

## Step 2 — Scope the work

List the files in the target area. Identify up to 4 independent sub-areas that can be analyzed in parallel (e.g. by layer: models, services, routes, tests).

---

## Step 3 — Call Task (parallel analysts)

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
    Write your findings to: docs/state/analysis-<sub-area-slug>-<YYYYMMDD>.md

    Structure:
    ### What this area does
    ### Key elements
    ### Relevant to the question
    ### Flags
    - [BLOCKER] <anything that prevents a clean answer>
    - [CRUFT] <dead or stale code found>
    - [GAP] <missing coverage or documentation>

    ## Return
    DONE: docs/state/analysis-<sub-area-slug>-<YYYYMMDD>.md | <one-line finding> [| BLOCKER | CRUFT | GAP]
)
```

Stamp each spawn:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "analyst → <sub-area>"
```

---

## Step 4 — Gate

After all Task calls complete:
- Verify each output file exists. If any is missing, re-run that Task before continuing.
- If any return contains `BLOCKER`: surface it to the user — do not synthesize until resolved.
- Stamp completions:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "analyst → docs/state/analysis-<sub-area>-<date>.md"
```

---

## Step 5 — Synthesize

Read all output files. Write `docs/state/analysis-summary-<YYYYMMDD>.md`:

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

---

## Step 6 — Stamp and hand off
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "analyze: complete — <one-line answer>"
```

Present the summary to the user. Propose the next step based on the `## Next step` field.
