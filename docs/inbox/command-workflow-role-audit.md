↑ [Inbox](index.md)

# Command → workflow → role/tools audit

**Issue (from a 2026-05-06 self-improve run):** The command → workflow → role/tools pattern was established as the standard architecture for all Shmorch commands. Existing commands were built before this standard and many carry their workflow steps inline in the command file rather than dispatching to a separate workflow.

**What to accomplish:**
- Audit all files in `commands/` against the pattern: command = short entry point + dispatch; workflow = all procedural steps; role = agent framing; tools = only for scripts that run outside sessions
- Commands known to carry inline steps (need workflow extraction): `wrap.md`, `go.md`, `self-improve.md`, `vacuum.md` (has a workflow file but the command may still have inline steps), `init.md`, `discover.md`
- For each command that needs it: create or extend the corresponding `workflows/<name>.md` and slim the command file down to dispatch + when-to-use
- This is a structural refactor of the skill itself — scope as a track if needed
