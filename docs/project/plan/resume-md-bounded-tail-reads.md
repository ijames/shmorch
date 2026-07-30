---
status: open
category: Fixes
---

↑ [Plan](index.md)

**resume.md: bounded-tail reads** — PR #57 bounded `session.md`/`timelog.md` reads in `orient.md`/`wrap.md`/`self-improve.md` but never extended the fix to `resume.md`, which still does a full `Read`. Concrete case 2026-07-21 (DarkBadge project): a plain `/shmorch resume` hit the 25K-token page-truncation cap on `plan.md` (531 lines) alone, on top of the token cost of reading it in full. (`workflows/resume.md`)
