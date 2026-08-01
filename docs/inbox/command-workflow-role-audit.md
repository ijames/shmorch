↑ [Inbox](index.md)
**In this section:** [Ambient/system-triggered state changes need smooth transitions, not just user-initiated ones](ambient-system-triggered-transitions.md) · [Backlog may be better modeled as a dependency stack than a flat list](backlog-dependency-stack.md) · [build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language](build-md-task-agent-protocol.md) · [New core doctrine: pnpm precedent for JS/TS projects](pnpm-precedent-js-tooling.md) · [Product design criteria: respect system settings by default](product-design-respect-system-settings.md) · [Session recaps should list files touched and any git PRs](session-recaps-files-touched.md) · [init — settings.json explanation](settings-json-explanation.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# Command → workflow → role/tools audit

**Issue (from a 2026-05-06 self-improve run):** The command → workflow → role/tools pattern was established as the standard architecture for all Shmorch commands. Existing commands were built before this standard and many carry their workflow steps inline in the command file rather than dispatching to a separate workflow.

**What to accomplish:**
- Audit all files in `commands/` against the pattern: command = short entry point + dispatch; workflow = all procedural steps; role = agent framing; tools = only for scripts that run outside sessions
- Commands known to carry inline steps (need workflow extraction): `wrap.md`, `go.md`, `self-improve.md`, `vacuum.md` (has a workflow file but the command may still have inline steps), `init.md`, `discover.md`
- For each command that needs it: create or extend the corresponding `workflows/<name>.md` and slim the command file down to dispatch + when-to-use
- This is a structural refactor of the skill itself — scope as a track if needed
