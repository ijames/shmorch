# Shmorch Task Protocol

How to spawn subagents with **your CLI's task/agent tool**. Every workflow that calls agents follows this protocol. The gates and prompt template are identical across CLIs; only the tool call differs (Claude `Agent` + `SendMessage`; omp / Pi `task` + `irc`; CLIs without subagents → do the role's work inline). Per-CLI mapping: `$SHMORCH_HOME/core/portability.md`.

---

## Cost discipline — read before spawning

Subagents start cold. Every spawn re-reads files, rebuilds context, and burns tokens. **Default: the orchestrator does it inline.** Spawn only when the task is parallelizable, role-specific, and has low file overlap with the current conversation.

When in doubt: do it yourself.

---

## When to spawn a subagent

Spawn when **all three** are true:
- **Parallelizable** — independent of other in-flight work; no shared write targets
- **Role-specific** — a different persona (analyst, architect, critic) genuinely improves the output
- **Low file overlap** — the agent won't re-read files already loaded in this conversation

Skip subagents for: single-file edits, questions, tasks under ~2 minutes, anything with high file overlap.

---

## One role per agent — name the session after the role

Each subagent gets exactly one role. Name the session after that role so it can be resumed instead of re-spawned. Use a model **tier**, never a vendor name: `default` for routine roles, `strong` for the critic.

**Claude Code:**
```
Agent(
  name: "<role>",              # "architect", "critic", "specwriter", etc.
  model: "haiku",              # default tier; use "sonnet" (strong) only when reasoning demands it
  description: "<Role>: <brief action>",
  prompt: "<full self-contained prompt — see template below>"
)
```
Resume a named agent (cheaper than re-spawning): `SendMessage(to: "<role>", message: "<follow-up>")`.

**omp / Pi:** spawn with the `task` tool (a `tasks[]` batch; each role maps to an agent type or a role prompt); message running agents via `irc`. Tiers: `default` / `slow` (strong).

**CLIs without subagents (Codex, Cursor, Gemini, opencode, Antigravity):** do not spawn — adopt the role yourself and do the work inline. The role file still frames the worldview.

Re-spawn only when the agent's task is complete or abandoned and a fresh context is needed.

---

## Agent prompt template

The prompt must be fully self-contained — the agent has no conversation history.

```
## Role
Read your role: check .shmorch/agents/roles/<name>.md first (project override);
if not present, use $SHMORCH_HOME/agents/roles/<name>.md (skill default).
Act according to that role only. Do not take on any other perspective.

## Task
<specific task — what to examine, build, or write>
Be explicit: name exact files to read, exact output path to write.

## Constraints
<any relevant constraints from stack.md, spec.md, or context.md — paste the relevant section, don't ask the agent to find it>

## Output
Write findings to: <exact file path>

Structure:
### Summary
<2-3 sentences>

### Details
<findings>

### Flags
- [BLOCKER] <description> — prevents proceeding
- [CRUFT] <description> — dead/stale/unused
- [GAP] <description> — missing but needed
(Omit sections with no entries.)

## Return
When done, output exactly:
DONE: <output file path> | <one-sentence summary> [| BLOCKER | CRUFT | GAP]
```

---

## Return value — orchestrator gates

The orchestrator must check every return line:

1. **Verify the output file exists** at the stated path
2. **Gate on BLOCKER** — if any agent returns BLOCKER, stop and surface to user before next phase
3. **Log CRUFT / GAP** — note in synthesis, continue

```
Gate: verify all outputs exist
  - <expected file> for each spawned agent
  - Missing file → agent failed; re-run or flag to user
  - BLOCKER → surface to user, do not proceed
  - CRUFT / GAP → record in synthesis doc, continue
```

---

## Parallel calls

Spawn multiple subagents in one step when they are truly independent (no shared write targets, no file overlap).

- **Claude Code:** multiple `Agent(...)` calls in one step (cap ~4 — more creates coordination overhead that erases the gain).
- **omp / Pi:** one `task` call with a `tasks[]` batch (the pool runs wider; still keep each batch focused).

```
# Claude Code example
Agent(name="analyst-src",   description="Analyst: src/", prompt=<...>)
Agent(name="analyst-tests", description="Analyst: tests/", prompt=<...>)
Agent(name="analyst-config", description="Analyst: config/", prompt=<...>)
# Wait for all, then gate
```

---

## Context hygiene — when to suggest a context reset (`/clear`, `/compact`, or your CLI's equivalent)

The orchestrator should remind the user at these moments:

| Trigger | Suggest |
|---|---|
| About to spawn agents and thread is long | `/compact` first — flush decisions to docs, then spawn |
| Phase boundary (spec done, design done) | `/clear` before starting next phase |
| Task shifts materially mid-session | `/clear` — fresh context is cheaper than a cluttered one |
| Thread has become tangled across multiple concerns | `/compact` — separate concerns before continuing |

Say it once: _"Good point to `/compact` before we spawn — want me to flush state first?"_
One reminder only. Never nag.

---

## Role resolution

Always resolve roles in this order:
1. `.shmorch/agents/roles/<name>.md` — project override
2. `$SHMORCH_HOME/agents/roles/<name>.md` — skill default

Include this line verbatim in every agent prompt:
```
Read your role: check .shmorch/agents/roles/<name>.md first; if not present, use $SHMORCH_HOME/agents/roles/<name>.md.
```

---

## Available roles

| Role | Tier | Purpose |
|---|---|---|
| `analyst` | default | Code analysis, pattern detection, flag identification |
| `architect` | default | Design decisions, structural proposals (no code) |
| `specwriter` | default | Spec documents from requirements |
| `implementer` | default | Code writing, test writing |
| `documentarian` | default | Doc generation and maintenance |
| `vacuumer` | default | Dead code and cruft detection |
| `sprinter` | default | Sprint tracking and scope management |
| `prioritizer` | default | Backlog ranking and effort assessment |
| `researcher` | default | Self-improve or external research analysis |
| `critic` | strong | Adversarial review at phase boundaries — finds failure modes |

---

## Timelog

```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "<role> → <target>"
# ... spawn call ...
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "<role> → <output file>"
```
