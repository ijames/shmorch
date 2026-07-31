# Shmorch Skill Notes

> **Structural note (2026-05-07):** Eventually shmorch will have its own `docs/` section and this file will migrate there. When that happens, NOTES.md becomes an index pointing into `docs/` rather than a flat append log.

---

## build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language

**Issue (2026-04-27):** The skill's `build.md` Step 3b uses rigid `Call Task (parallel implementers)` framing. In practice the decision of whether to use a sub-agent vs. implementing in the main task depends on factors the skill doesn't account for: complexity of the context handoff, how isolated the module truly is, and whether the communication overhead of a Task prompt is worth it.

_(partial — the richer DoD checklist language (tests question, track scoping guard, commit-grouping language, Checklist Summary block) landed via PR #81; an adversarial verification pass was also added via PR #82. The spawn-decision reframe itself — renaming Step 3b to "spawn Task agents" and loosening the trigger to default-Task/inline-exception — is still open; scoped out deliberately during 2026-07-30 self-improve pending a developer call on whether it should fold into a bigger Workflow-orchestration redesign of Step 3b.)_

**What to consider:**
- Rename Step 3b from "Call Task (parallel implementers)" to "spawn Task agents" and reframe the decision rule to lean toward calling Tasks: "Call Task agents for each module — unless the module is so tightly entangled with in-flight context that fully briefing an agent would cost more than implementing it directly. Default is Task; inline is the exception."

## Command → workflow → role/tools audit (from 2026-05-06 self-improve)

**Issue:** The command → workflow → role/tools pattern was established as the standard architecture for all Shmorch commands. Existing commands were built before this standard and many carry their workflow steps inline in the command file rather than dispatching to a separate workflow.

**What to accomplish:**
- Audit all files in `commands/` against the pattern: command = short entry point + dispatch; workflow = all procedural steps; role = agent framing; tools = only for scripts that run outside sessions
- Commands known to carry inline steps (need workflow extraction): `wrap.md`, `go.md`, `self-improve.md`, `vacuum.md` (has a workflow file but the command may still have inline steps), `init.md`, `discover.md`
- For each command that needs it: create or extend the corresponding `workflows/<name>.md` and slim the command file down to dispatch + when-to-use
- This is a structural refactor of the skill itself — scope as a track if needed

---

## Backlog may be better modeled as a dependency stack than a flat list

**Issue (2026-05-07):** When work items block each other (e.g. equity-factory → order-price-gherkin), a flat domain list doesn't surface the push/pop relationship. The developer had to mentally track "do this first" without structural support.

**What to consider:**
- plan.md's backlog could have a formal "Active Stack" section at the top where blocked chains are pushed and popped in dependency order, separate from the flat domain inventory below.
- This is a LIFO model for the hot path: top of stack = do next; bottom = not yet unblocked.
- Relates to the Beads/Conductor evaluation already in the backlog — a proper dependency graph tool would make this structural rather than prose.
- Very loose for now — worth revisiting if dependency chains become common.
