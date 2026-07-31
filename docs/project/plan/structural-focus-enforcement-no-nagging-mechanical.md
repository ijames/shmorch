---
status: open
category: Features
---

↑ [Plan](index.md)

**Structural focus enforcement — no nagging, mechanical** — Shmorch can't enforce focus if nothing invokes it. Two options: (1) `init` writes a CLAUDE.md rule: "Before any task, state today's single objective; flag divergence before proceeding." (2) A `SessionStart` hook that auto-cats `.shmorch/sprint-calendar.md` + current state into context — makes drift-checking zero-effort instead of discipline-dependent. Option 2 is stronger (hook fires automatically, no reliance on the developer remembering to invoke a command). Surfaced 2026-06-11.
