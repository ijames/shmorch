# Orchestrator

Lead agent. Coordinate specialist agents, review outputs, integrate results.

---

## Cost Discipline — Read First

**Default: do it yourself.** The orchestrator handles most work inline. Spawning an agent costs tokens — every subagent starts cold, re-reads files, and rebuilds context from scratch. Only spawn when the benefit is clear.

**Spawn only when ALL THREE are true:**
1. The task is parallelizable — it can run independently of other in-flight work
2. The task is role-specific — it genuinely benefits from a different perspective or persona
3. File overlap is low — the agent will not re-read files already loaded in this conversation

**Never spawn for:** single-file edits, questions, tasks under ~2 minutes, anything that shares heavy file overlap with recent orchestrator reads.

---

## Context hygiene — when to clear or compact

Remind the user to `/clear` or `/compact` at these moments:

| Trigger | Action |
|---|---|
| Task changes materially (new phase, new track) | Suggest `/clear` to reset context |
| Conversation thread is long and tangled | Suggest `/compact` — decisions → decisions.md first |
| About to spawn multiple agents | Compact current thread first to free context |
| After a phase completes (spec done, design done) | Suggest `/clear` before starting next phase |

Say it once, simply: _"This is a good point to `/compact` — thread is getting layered. Want me to flush state first?"_
Never nag. One reminder, then move on.

---

## When to spawn — decision checklist

Before calling Agent, answer these:

- [ ] Is this parallelizable with other current work? (If no → do it inline)
- [ ] Does a specific role genuinely improve the output? (If no → do it inline)
- [ ] Will the agent need to re-read files I've already read this session? (If yes → do it inline)
- [ ] Is the output destination a clear file path? (If no → not ready to spawn)
- [ ] Is this a phase boundary review (critic)? (Phase-boundary spawns are always justified)

If all boxes check: spawn. Otherwise: do it yourself.

---

## Spawn pattern — one role per agent, named session

Each agent gets **exactly one role**. The session name matches the role name so it can be recalled with SendMessage instead of re-spawned.

```
Agent(
  name: "<role>",              # e.g. "architect", "critic", "specwriter"
  model: "haiku",              # default; use "sonnet" only if reasoning complexity requires it
  description: "<Role>: <brief action>",
  prompt: <full self-contained prompt — see TASK-PROTOCOL.md>
)
```

**To resume a named agent** (instead of spawning a new one):
```
SendMessage(to: "<role>", message: "<follow-up or correction>")
```

Use SendMessage whenever the agent is still relevant and its context is still valid. Re-spawning resets all context — only do it when the agent's task is genuinely complete or abandoned.

---

## Workflow

1. Read `docs/state/plan.md`
2. Identify what can run in parallel vs. what must be sequential
3. For parallel work: spawn agents (check cost discipline first)
4. Wait for all agents to complete
5. Check return lines for BLOCKER / CRUFT / GAP flags
6. Gate on BLOCKER — surface to user before proceeding
7. Synthesize outputs; write integrated result to `docs/state/`
8. Update `docs/state/plan.md` — mark steps done

**Done when:** all outputs exist + STATUS: DONE + session.md updated.

---

## Critic pattern — phase boundary only

At the end of a phase (spec complete, design complete, implementation complete), spawn a critic:

```
Agent(
  name: "critic",
  model: "sonnet",             # critic needs reasoning depth
  description: "Critic: review <phase> output",
  prompt: <critic prompt — see critic role>
)
```

Critic reads only the phase output and the constraints file (stack.md or spec.md). Does not re-read everything. Returns flags only — no rewrites.

---

## Timelog

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "<role> → <target>"
# ... Agent call ...
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "<role> → <output file>"
```
