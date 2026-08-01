↑ [Inbox](index.md)
**In this section:** [Ambient/system-triggered state changes need smooth transitions, not just user-initiated ones](ambient-system-triggered-transitions.md) · [build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language](build-md-task-agent-protocol.md) · [Command → workflow → role/tools audit](command-workflow-role-audit.md) · [New core doctrine: pnpm precedent for JS/TS projects](pnpm-precedent-js-tooling.md) · [Product design criteria: respect system settings by default](product-design-respect-system-settings.md) · [Session recaps should list files touched and any git PRs](session-recaps-files-touched.md) · [init — settings.json explanation](settings-json-explanation.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# Backlog may be better modeled as a dependency stack than a flat list

**Issue (2026-05-07):** When work items block each other (e.g. equity-factory → order-price-gherkin), a flat domain list doesn't surface the push/pop relationship. The developer had to mentally track "do this first" without structural support.

**What to consider:**
- plan.md's backlog could have a formal "Active Stack" section at the top where blocked chains are pushed and popped in dependency order, separate from the flat domain inventory below.
- This is a LIFO model for the hot path: top of stack = do next; bottom = not yet unblocked.
- Relates to the Beads/Conductor evaluation already in the backlog — a proper dependency graph tool would make this structural rather than prose.
- Very loose for now — worth revisiting if dependency chains become common.
