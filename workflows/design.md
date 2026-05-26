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

## Step 1b — Stack compatibility gate (run before spawning the architect)

If the tech stack is still being settled **or** this feature adds a new integration point between systems, run this gate before calling the architect. Skip silently if the stack is fully locked and no new integration points are introduced.

For each requirement in the spec, answer:

1. **Dev-to-prod parity** — does this requirement behave identically in dev and production?
   - Flag anything that works in dev but has a known production constraint (e.g. streaming responses buffered by an API gateway, long-running jobs killed by a hosting timeout, file system writes unavailable in a serverless environment).
   - For each flag: state the gap and the effort required to bridge it. If the effort is high or the workaround changes the approach significantly, surface it as a decision before proceeding.
   - **For any transport or protocol choice (SSE, WebSockets, streaming, chunked responses):** trace the full request path layer by layer and verify each layer supports it. Name every layer explicitly — e.g. `Lambda function → ASGI adapter → invoke mode → Function URL → CDN/proxy → client`. One layer that can't pass the protocol through invalidates the whole choice. Do not assume support; look it up for each layer. This check is mandatory before committing to any non-standard transport.

2. **Integration effort** — enumerate every glue point between disparate systems this feature requires (e.g. Vercel ↔ Lambda auth/CORS, SSE passthrough, SQS trigger wiring, Neon connection pooling on Lambda cold starts). For each:
   - Estimate the wiring effort: low (< 1 hr), medium (1–4 hrs), high (4+ hrs)
   - Note any "works in dev only" risk

3. **Cost dimensions** — for each approach being considered, explicitly compare:
   - **Time cost**: wiring effort, debugging prod-only issues, integration testing
   - **Monetary cost**: per-request pricing, egress fees, cold-start overhead
   - **Risk**: anything that is "green in dev, broken in prod" is high-risk and must be resolved before the build starts — not discovered during it

4. **Record findings** — if any flag, gap, or trade-off is non-trivial, record it now in `docs/development/decisions.md` under a dated entry titled "Stack compatibility: <feature>". This creates the paper trail if the approach needs to be reconsidered later.

If Step 1b finds a blocking incompatibility (a requirement that cannot be met by the chosen stack without significant rework): surface it to the developer now, before the architect is spawned. Do not proceed to Step 2 until resolved.

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
    - For each approach: integration effort (low/medium/high), dev-to-prod parity risk, and cost dimensions (time, money, risk)

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
    | Approach | Pros | Cons | Integration effort | Dev-to-prod risk |
    |---|---|---|---|---|
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
