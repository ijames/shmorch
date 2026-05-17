# Workflow: Design

Produce an architectural design before implementation. Reads the spec, proposes structure, records decisions.

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## When to use
- After a spec is approved and before writing any code
- When the outcome is clear but the approach has open decisions
- When the user says "how should we build this?"

## Inputs

- Approved spec (`docs/state/spec.md` or track-level spec)
- Stack constraints (`docs/state/stack.md`)
- Existing architecture (`docs/architecture/` if present)

## Roles
- `agents/roles/architect.md`

---

## Step 1 — Stamp
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "design: starting — <feature>"
```

---

## Step 2 — Call Task (architect)

```
Task(
  description: "Architect: <feature>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/architect.md` first (project override); if not present, use `~/.claude/skills/shmorch/agents/roles/architect.md` (skill default). Act according to the role definition found.

    ## Task
    Produce an architectural design for the feature described in: docs/state/spec.md

    Also read:
    - docs/state/stack.md — respect all version constraints and external limits
    - docs/architecture/ — check for existing patterns to follow or extend

    The design must cover:
    - Where this feature lives in the existing structure (new files, new modules, or extension of existing ones)
    - Data model changes (if any)
    - Key interfaces or contracts between components
    - What must NOT change (constraints from stack or architecture)
    - Two or three implementation approaches with tradeoffs — recommend one

    ## Output
    Write the design to: docs/state/design-<feature-slug>.md

    Structure:
    ### Design: <feature>
    **Date:** <today>
    **Spec:** docs/state/spec.md

    ### Placement
    ### Data model
    ### Interfaces
    ### Constraints
    ### Approaches considered
    | Approach | Pros | Cons |
    |---|---|---|
    ### Recommendation
    ### Open decisions
    - [ ] <decision needed — default: <default if developer doesn't respond>>

    ## Return
    DONE: docs/state/design-<feature-slug>.md | <one-line approach summary> [| BLOCKER if a constraint makes any approach unworkable]
)
```

Stamp:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "architect → <feature>"
```

---

## Step 3 — Gate

Verify `docs/state/design-<feature-slug>.md` exists.
If BLOCKER: surface constraint conflict to developer — do not proceed.

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "architect → docs/state/design-<feature-slug>.md"
```

---

## Step 4 — Review open decisions

Present the design. For each open decision: ask the developer once, record the answer in `docs/development/decisions.md`:

```markdown
### [YYYY-MM-DD] <decision title>
**Context:** <why this needed deciding>
**Decision:** <what was decided>
**Rationale:** <why>
```

Rewrite the design to reflect the decisions made (no amendments — clean current state).

---

## Step 5 — Decision closure sweep

Before closing the design session, scan `docs/development/decisions.md` for any entries containing "open", "TBD", "next session", or unchecked `- [ ]` items.

For each open decision found:
- Attempt to resolve it now using available context
- If resolvable: record it in decisions.md and update the design doc
- If not resolvable: state the **specific blocker** — a named dependency, a missing constraint, a question only the developer can answer. "Decide next session" is not acceptable without a named blocker.

This step exists because architecture decisions cluster — resolving one often unblocks adjacent ones. Deferring without a specific reason loses that momentum across context windows.

---

## Step 6 — Stamp and hand off
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "design: approved — <approach>"
```

Update `docs/state/plan.md` track status to `Design done`. Propose: "Ready to build."
