---
status: Open
category: process
updated: 2026-08-09
---

**In this section:** see [index](index.md) for siblings.

# Prompt goal-alignment / scope monitor

**Why this exists:** raised at 2026-08-09 wrap. Without sprints or deadlines, scope
discipline on a solo project runs on impulse, sensitivity, and ad-hoc prioritization alone —
there's no external forcing function. A given prompt/request can be a "now" thing, a
"later" thing, or something that should get bundled into an existing track/feature instead
of starting a new thread — but nothing currently helps make that call before work starts.

**Idea:** some kind of lightweight check, run against an incoming prompt/directive, that
estimates distance from current goals/active track and suggests one of: proceed now,
defer to backlog, or fold into an existing track/feature. Not meant to gate or nag — more a
single reflective prompt at the point of intake, similar in spirit to `prioritize`'s
scoring but applied earlier, before a track even exists.

**Open questions:**
- Is this a `prioritize`-workflow extension (score on intake, not just backlog) or a
  separate lightweight check?
- Deterministic heuristic (keyword/track-file overlap) vs. an AI judgment call — cost/value
  tradeoff for something meant to run on every prompt, not just at session boundaries.
- Risk of becoming exactly the kind of mechanical nagging `structural-focus-enforcement-no-nagging-mechanical.md`
  already warns against — needs to stay a prompt, not a gate.
