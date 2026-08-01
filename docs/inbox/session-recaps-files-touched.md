↑ [Inbox](index.md)
**In this section:** [Ambient/system-triggered state changes need smooth transitions, not just user-initiated ones](ambient-system-triggered-transitions.md) · [Backlog may be better modeled as a dependency stack than a flat list](backlog-dependency-stack.md) · [build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language](build-md-task-agent-protocol.md) · [Command → workflow → role/tools audit](command-workflow-role-audit.md) · [New core doctrine: pnpm precedent for JS/TS projects](pnpm-precedent-js-tooling.md) · [Product design criteria: respect system settings by default](product-design-respect-system-settings.md) · [init — settings.json explanation](settings-json-explanation.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# Session recaps should list files touched and any git PRs

**Issue (2026-07-29):** End-of-response/session recaps in Shmorch-driven work summarize *what* was decided or built in prose, but don't consistently enumerate the concrete artifacts changed — which files were touched, and whether a PR/commit was opened. The developer (James) wants this reliably present, not just when it happens to be relevant to the prose summary.

**What to consider:**
- Wherever Shmorch produces a recap (end-of-turn summary, `wrap.md` session close, track status updates), append a short "Files touched" list (paths only, no diff) and a "PR/commit" line (link or "none this session") when applicable.
- Likely touches `workflows/wrap.md` (session close report) and possibly `shmorch-core.md`'s general "end-of-response" expectations — decide whether this is a wrap-only requirement or applies to every substantive response.
- Keep it terse — a flat file list and one PR line, not a full diff or changelog prose.
