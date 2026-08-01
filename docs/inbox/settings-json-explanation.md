↑ [Inbox](index.md)
**In this section:** [Ambient/system-triggered state changes need smooth transitions, not just user-initiated ones](ambient-system-triggered-transitions.md) · [Backlog may be better modeled as a dependency stack than a flat list](backlog-dependency-stack.md) · [build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language](build-md-task-agent-protocol.md) · [Command → workflow → role/tools audit](command-workflow-role-audit.md) · [New core doctrine: pnpm precedent for JS/TS projects](pnpm-precedent-js-tooling.md) · [Product design criteria: respect system settings by default](product-design-respect-system-settings.md) · [Session recaps should list files touched and any git PRs](session-recaps-files-touched.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# init — settings.json explanation

**Issue (2026-04-01):** During `/shmorch init`, the user paused when Claude wrote `.shmorch/.claude/settings.json` and asked why it was needed. The init command doesn't explain the purpose of any files it creates.

**What to consider:**
- Add a brief explanation in Step 3 of `commands/init.md` or in Step 7 (the report) describing what `.shmorch/.claude/settings.json` does: it wires up pre-tool safety hooks (blocks `rm -rf`, `git push --force`) and pre-allows common read-only commands.
- Alternatively, add a `## What Got Created` section to the Step 7 report so users understand what they're getting.
- The user was fine proceeding once explained — this is a "explain proactively" gap, not a design problem.
