---
status: open
category: Architecture
---

↑ [Plan](index.md)

**Workflow subagent delegation** — run rote, shmorch-specific (not project-specific) workflow steps as subagents instead of inline on the main thread: `go`/`resume`/`wrap` follow a clear deterministic path today but still pay full file-read cost in main-thread context; move that cost into a disposable subagent context and return a small structured JSON package sized to the caller (rich for go/resume — focus, active track, next moves; thin for wrap/self-improve/documentarian — pass/fail + summary). Deterministic version/patch mechanics stay scripted, not agent-ified. Surfaced 2026-07-21. → [track](../tracks/20260721-workflow-subagent-delegation/index.md)
