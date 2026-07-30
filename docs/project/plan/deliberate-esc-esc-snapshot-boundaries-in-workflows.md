---
status: open
category: Features
---

↑ [Plan](index.md)

**Deliberate Esc-Esc snapshot boundaries in workflows** — Claude Code's Esc-Esc rolls back to any prior conversation checkpoint non-destructively. Shmorch should design workflow boundaries to be clean Esc-Esc targets: flush all state to files first, emit a clean one-liner summary, then launch any heavy subagent work. Pattern: `[write session.md + timelog] → [clean pause line] → [spawn subagent]`. This makes rollback cheap — only steering messages are lost, not inline analysis. Applies especially to `go` (before auto-update), `build` (before each phase), `documentarian`. Subagent model enhances this: main thread checkpoints stay clean and meaningful.
