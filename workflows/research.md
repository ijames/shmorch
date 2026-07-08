# Workflow: research

Proactive external research. Finds advances in AI-assisted development and LLM orchestration practices, then proposes specific improvements to shmorch.

## When to use
- Start of a new sprint, before planning
- After a major Claude Code release or Anthropic announcement
- Whenever shmorch's patterns may be behind current practice

## Inputs
- Optional focus area from user (or default broad sweep)

## Roles
- `agents/roles/researcher.md` (extrospective mode — web search required)

---

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## Step 1 — Stamp
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "research: starting external practice review"
```

---

## Step 2 — Optional: focus the search

Ask the developer (one question):

> "Any specific area to focus on — agent patterns, workflow structure, state management, something else? Or broad sweep?"

Use the answer to shape the Task prompt. If they say broad, proceed with the defaults below.

---

## Step 3 — Call Task (researcher, extrospective mode)

```
Task(
  description: "Researcher: external practice research",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/researcher.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/researcher.md` (skill default). Act according to the role definition found.
    You are operating in EXTROSPECTIVE mode: use web search to find external evidence.

    ## Task
    Research current best practices in AI-assisted software development, focusing on:
    <focus area from Step 2, or defaults below>

    Default search areas:
    1. Claude Code agent patterns and subagent coordination (2025–2026)
    2. LLM-driven development workflow design — what's working, what's not
    3. Multi-agent orchestration patterns for software development
    4. State management approaches for long-running LLM dev sessions
    5. Prompt engineering advances for code generation and review

    For each area:
    - Find 2–3 credible sources (Anthropic docs, practitioner writeups, research papers)
    - Extract the specific practice or capability
    - Assess applicability to shmorch: does it apply? Is it already present? What would change?

    Produce proposals only for practices that are (a) clearly working, (b) applicable, (c) not already in shmorch.

    ## Output
    Write your research and proposals to: $SHMORCH_HOME/research/research-<YYYYMMDD>.md
    (create the directory if it doesn't exist)
    Research reports are skill-level artifacts — they inform shmorch improvements across all projects, not just the current one. Do not write them into the project's docs/state/.

    Structure:
    ### Research Report — <date>
    **Focus:** <area>

    ### Findings

    For each finding:
    #### Finding N: <practice name>
    **Source:** <URL or citation>
    **What it is:** <2 sentences>
    **Already in shmorch?** Yes / Partially / No
    **Applicability:** High / Med / Low — <one sentence why>

    ### Proposals

    For each actionable finding:
    #### Proposal N: <title>
    **Based on:** Finding N
    **File to change:** <path>
    **Proposed change:** <specific>
    **Expected improvement:** <what gets better>

    ### Deferred
    <findings that are real but not applicable now — note what would need to change for them to become relevant>

    ## Return
    DONE: $SHMORCH_HOME/research/research-<YYYYMMDD>.md | <N findings, M proposals> [| BLOCKER if search returned no usable results]
)
```

Stamp:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "researcher → external research"
```

---

## Step 4 — Gate

Verify `$SHMORCH_HOME/research/research-<date>.md` exists.
If BLOCKER: web search may have failed — ask the developer if they want to retry with a narrower focus.

```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "researcher → $SHMORCH_HOME/research/research-<date>.md"
```

---

## Step 4b — Save valuable references to memory

For each finding rated High or Med applicability, write a `reference` memory entry to the project memory directory (`~/.claude/projects/<project-slug>/memory/`).

File naming: `reference_<slug>.md` (e.g. `reference_anthropic_context_engineering.md`)

Format:
```markdown
---
name: <source title>
description: <one-line: what it covers and why it's relevant to this project>
type: reference
---

<URL> — <what to find there: specific section, pattern, or concept worth returning to>
```

Add each new entry to the project's `MEMORY.md` index (one line: `- [Title](file.md) — hook`).

Skip sources already in MEMORY.md. Do not create duplicate entries.

---

## Step 5 — Review with developer

Present findings summary first (not proposals yet):

> "Found N relevant practices. M are already in shmorch, K are new. Want to see the proposals?"

Then present each proposal one at a time, same as sync:

> "Proposal N: <title>
> Based on: <source>
> Change: <specific>
> Apply? (yes / no / modify)"

One at a time. No batch-applying.

When applying changes, use the same target rules as sync:
- `commands/`, `shmorch-core.md`, `agents/` → SKILL at `$SHMORCH_HOME/<path>`
- `.shmorch/workflows/` → project-local copy at `.shmorch/workflows/<file>`
- Bump `$SHMORCH_HOME/VERSION` after any skill-level change.

---

## Step 6 — Stamp
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "research: complete — <M> changes applied"
```

Keep `$SHMORCH_HOME/research/research-<date>.md` — it's a permanent record. Do not delete it.
