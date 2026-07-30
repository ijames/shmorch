---
status: open
category: Features
---

↑ [Plan](index.md)

**`/shmorch verify` parity check command** — Docs↔tests↔code parity check: README audit (exists, project-specific, run commands accurate), structure gaps (expected files per component), scenario→step definition coverage (GREEN/RED/MISSING), docs→scenario coverage (undocumented claims), setup.md command accuracy. Writes `docs/state/parity-report-YYYY-MM-DD.md`. Current stack-specific prototype in `js/hack:workflows/verify.md` — generalize for any stack. Gaps surface as plan.md items; never silently pass.
