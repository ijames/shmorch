---
status: open
category: Design & Docs
---

↑ [Plan](index.md)

**Subagent usage guide for solo dev** — document when/how Shmorch spawns subagents during solo development: parallel test-writing while fixing, research isolation, Gherkin generation. Goal: proactively spawns without being asked.
  - Candidate patterns: subagent writes tests → main thread validates; subagent researches root cause → main thread decides fix; subagent writes docs in parallel with code
  - Moved from: MoBoS plan.md 2026-05-19
