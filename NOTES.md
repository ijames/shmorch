# Shmorch Skill Notes

> **Structural note (2026-05-07):** Eventually shmorch will have its own `docs/` section and this file will migrate there. When that happens, NOTES.md becomes an index pointing into `docs/` rather than a flat append log.

---

## init — settings.json explanation

**Issue (2026-04-01):** During `/shmorch init`, the user paused when Claude wrote `.shmorch/.claude/settings.json` and asked why it was needed. The init command doesn't explain the purpose of any files it creates.

**What to consider:**
- Add a brief explanation in Step 3 of `commands/init.md` or in Step 7 (the report) describing what `.shmorch/.claude/settings.json` does: it wires up pre-tool safety hooks (blocks `rm -rf`, `git push --force`) and pre-allows common read-only commands.
- Alternatively, add a `## What Got Created` section to the Step 7 report so users understand what they're getting.
- The user was fine proceeding once explained — this is a "explain proactively" gap, not a design problem.

## State + docs should update continuously, not just at wrap

**Issue (2026-04-04):** State was only written at the end of the session (via /shmorch wrap). User expects state files and docs to be updated as work happens — not batched at the end.

**What to consider:**
- `go.md` and `build.md` should reinforce: update `plan.md` when a track starts/finishes a step, update `decisions.md` when a decision is made, update `stack.md` when a constraint is discovered — all in the moment, not deferred.
- The timelog already does this (stamps at every event) — state files should follow the same pattern.
- Docs (inline comments, architecture docs) should be updated alongside the code change, not as a separate pass.
- This is a "continuous not batched" principle worth making explicit in `shmorch-core.md` and `go.md`.

## build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language

**Issue (2026-04-27):** The skill's `build.md` Step 3b uses rigid `Call Task (parallel implementers)` framing. In practice the decision of whether to use a sub-agent vs. implementing in the main task depends on factors the skill doesn't account for: complexity of the context handoff, how isolated the module truly is, and whether the communication overhead of a Task prompt is worth it.

**What to consider:**
- Rename Step 3b from "Call Task (parallel implementers)" to "spawn Task agents" and reframe the decision rule to lean toward calling Tasks: "Call Task agents for each module — unless the module is so tightly entangled with in-flight context that fully briefing an agent would cost more than implementing it directly. Default is Task; inline is the exception."
- The project's `build-pre-task.md` (pre-2026-04-27 version) has a cleaner Definition of Done with richer checklist language — specifically:
  - The Tests section asks "did any new public methods get added or changed?" rather than a flat bullet — this surfaces the question more reliably
  - The Track section includes "fill in ↑ source and → destination links before writing anything else — if you can't fill in the destination, the track isn't scoped" — this is a strong scoping guard that should be in the skill
  - The Commit grouping section uses stronger language: "If tests or docs are missing, do not commit the code alone. Either finish them or create a track step to complete them and note the gap explicitly."
- The skill's DoD is a condensed version that loses these nuances. Adopt the richer project language into the skill's Step 4.
- Add the Checklist Summary block (the four-item pre-commit checklist) from the project version — it's a useful at-a-glance gate that the skill's version is missing.

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

---

## Shmorch should be proactive, not passive — never just stop

**Issue (2026-04-04):** When the user asked "where are we?" and then said "not yet" to starting a track, Shmorch answered the question and went quiet. It should have kept driving.

**What to consider:**
- Shmorch is the active development lead. Unless the user explicitly says "done for now" or "quit", it should always propose a next move.
- After answering a status question, follow up: "Want me to start on docs-audit now? I can dig into what's actually in the docs directory and give you a picture before we commit to the track."
- When there are gaps (unfilled context.md fields, empty stack sections, unverified assumptions), surface them proactively: "Your context.md still has placeholder preferences — want to fill those in? It'll help when we get to the commit and test tracks."
- When the user says "not yet" to starting work, don't stop — ask what's holding them back or offer something smaller: analysis, a quick audit, filling in state, answering a question about the codebase.
- The right mental model: Shmorch is a dev lead who keeps the project moving, not a tool that answers questions and waits. It should feel like pairing with someone who always has a suggestion for what to do next.
- Add to `go.md`: after asking "what do you want to work on?" and getting a non-answer, offer 2-3 concrete options rather than going silent.
