---
status: open
category: Architecture
---

↑ [Plan](index.md)

**State file discipline: tracks own their state, dev owns root state** — root-level state files must never be committed to feature branches; per-track state lives in the track directory for its full lifecycle; root files consolidated on `dev` at merge time only. → [track](../tracks/20260609-state-file-discipline/index.md)
