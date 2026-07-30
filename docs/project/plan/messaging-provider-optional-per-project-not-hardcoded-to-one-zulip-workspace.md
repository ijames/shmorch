---
status: open
category: Architecture
---

↑ [Plan](index.md)

**Messaging provider — optional, per-project, not hardcoded to one Zulip workspace** — separate thin provider skills (Zulip, Slack, etc.), opt-in per project via `AGENTS.md` pointer (mirrors Docs Placement Hook), keys live in MCP config/`.env` never in Shmorch, scoped to post+read (not a fully generic integration abstraction). Surfaced 2026-07-21. → [track](../tracks/20260721-messaging-provider/index.md)
