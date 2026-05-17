# Shmorch Task Protocol

How to spawn subagents using the Claude Code `Agent` tool. All workflow files that call agents must follow this protocol exactly.

---

## Cost discipline — read before spawning

Subagents start cold. Every spawn re-reads files, rebuilds context, and burns tokens. **Default: the orchestrator does it inline.** Spawn only when the task is parallelizable, role-specific, and has low file overlap with the current conversation.

When in doubt: do it yourself.

---

## When to call Agent

Call Agent when **all three** are true:
- **Parallelizable** — independent of other in-flight work; no shared write targets
- **Role-specific** — a different persona (analyst, architect, critic) genuinely improves the output
- **Low file overlap** — the agent won't re-read files already loaded in this conversation

Skip Agent for: single-file edits, questions, tasks under ~2 minutes, anything with high file overlap.

---

## One role per agent — session named after the role

Each agent gets exactly one role. Name the session after that role so it can be resumed with SendMessage instead of re-spawned.

```
Agent(
  name: "<role>",              # "architect", "critic", "specwriter", etc.
  model: "haiku",              # default; escalate to "sonnet" only if reasoning complexity requires it
  description: "<Role>: <brief action>",
  prompt: "<full self-contained prompt — see template below>"
)
```

**To resume a named agent** (cheaper than re-spawning):
```
SendMessage(to: "<role>", message: "<follow-up or clarification>")
```

Re-spawn only when the agent's task is complete or abandoned and a fresh context is needed.

---

## Agent prompt template

The prompt must be fully self-contained — the agent has no conversation history.

```
## Role
Read your role: check .shmorch/agents/roles/<name>.md first (project override);
if not present, use ~/.claude/skills/shmorch/agents/roles/<name>.md (skill default).
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

Call multiple Agents in one step when they are truly independent (no shared write targets, no file overlap).

```
# Spawn in parallel
Agent(name="analyst-src",   description="Analyst: src/", prompt=<...>)
Agent(name="analyst-tests", description="Analyst: tests/", prompt=<...>)
Agent(name="analyst-config", description="Analyst: config/", prompt=<...>)

# Wait for all, then gate
```

Maximum 4 parallel agents. More than that creates coordination overhead that erases the gain.

---

## Context hygiene — when to suggest /clear or /compact

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
2. `~/.claude/skills/shmorch/agents/roles/<name>.md` — skill default

Include this line verbatim in every agent prompt:
```
Read your role: check .shmorch/agents/roles/<name>.md first; if not present, use ~/.claude/skills/shmorch/agents/roles/<name>.md.
```

---

## Available roles

| Role | Model | Purpose |
|---|---|---|
| `analyst` | haiku | Code analysis, pattern detection, flag identification |
| `architect` | haiku | Design decisions, structural proposals (no code) |
| `specwriter` | haiku | Spec documents from requirements |
| `implementer` | haiku | Code writing, test writing |
| `documentarian` | haiku | Doc generation and maintenance |
| `vacuumer` | haiku | Dead code and cruft detection |
| `sprinter` | haiku | Sprint tracking and scope management |
| `prioritizer` | haiku | Backlog ranking and effort assessment |
| `researcher` | haiku | Self-improve or external research analysis |
| `critic` | sonnet | Adversarial review at phase boundaries — finds failure modes |

---

## Timelog

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "<role> → <target>"
# ... Agent call ...
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "<role> → <output file>"
```
