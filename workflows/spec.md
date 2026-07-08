# Workflow: Spec

Define what to build before building it. Produces a spec in `docs/state/spec.md` (or a track-level spec).

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## When to use
- When the outcome is unclear — "what exactly are we building?"
- Before writing any code or design
- Routed here from Intake or Navigate

## Universal rules (apply regardless of project)

- **Product spec precedes tech choices.** User stories and acceptance criteria must be written before any technology is selected or assumed. In R&D and proof-sprint stages especially: understanding what to build is a prerequisite for choosing how to build it.
- **Tech stack stays TBD until explicit confirmation.** Never promote a candidate technology to a decision because it was mentioned or seems likely. Mark as `(candidate)` until the developer explicitly confirms it.

## Inputs

- Feature or track name
- Any existing analysis (`docs/state/analysis-*.md`) or design context

## Roles
- `agents/roles/specwriter.md`

---

## Step 1 — Stamp
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "spec: starting — <feature>"
```

---

## Step 2 — Interview (95% confidence)

Before calling any agent, interview the user until you have 95% confidence about:
- What outcome they want (not just what they described)
- What is explicitly out of scope
- What constraints apply (stack, existing APIs, data model)
- What "done" looks like

Ask one question at a time. Do not proceed to Step 3 until confident.

---

## Step 3 — Call Task (specwriter)

```
Task(
  description: "Specwriter: <feature>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/specwriter.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/specwriter.md` (skill default). Act according to the role definition found.

    ## Task
    Write a spec for: <feature>

    Developer-provided context:
    <summary of interview answers>

    Existing analysis (if any): read docs/state/analysis-*.md files relevant to this feature.

    The spec must answer:
    - What is being built and why
    - What it does (behaviour, not implementation)
    - What it does NOT do (explicit non-goals)
    - Acceptance criteria (testable conditions for "done")
    - Open questions that need a decision before implementation

    ## Output
    Write the spec to: docs/state/spec.md
    (If this is a track-level spec, write to docs/state/tracks/<track-name>/spec.md instead — use whichever path was specified.)

    Structure:
    ### Feature: <name>
    **Status:** Draft
    **Date:** <today>

    ### Why
    ### What it does
    ### What it does NOT do
    ### Acceptance criteria
    - [ ] <testable condition>
    ### Open questions
    - [ ] <question — owner: developer>

    ## Return
    DONE: docs/state/spec.md | <one-line feature summary> [| BLOCKER if any open question blocks writing the spec]
)
```

Stamp:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "specwriter → <feature>"
```

---

## Step 4 — Gate

Verify `docs/state/spec.md` exists.
If BLOCKER: surface the open question to the developer and resolve before continuing.

```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "specwriter → docs/state/spec.md"
```

---

## Step 5 — Review

Present the spec to the developer. Ask: "Does this capture what you want, or anything to adjust?"

Incorporate feedback and rewrite the spec in place (not appended — see shmorch-core.md: Documents stay clean).

---

## Step 6 — Stamp and hand off
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "spec: approved — <feature>"
```

Update `docs/state/plan.md` to set the track status to `Spec done`. Propose: "Ready to design, or go straight to build?"
