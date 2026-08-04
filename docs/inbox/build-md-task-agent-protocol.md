↑ [Inbox](index.md)
**In this section:** [Backlog may be better modeled as a dependency stack than a flat list](backlog-dependency-stack.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md)

# build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language

**Issue (2026-04-27):** The skill's `build.md` Step 3b uses rigid `Call Task (parallel implementers)` framing. In practice the decision of whether to use a sub-agent vs. implementing in the main task depends on factors the skill doesn't account for: complexity of the context handoff, how isolated the module truly is, and whether the communication overhead of a Task prompt is worth it.

**What to consider:**
- Rename Step 3b from "Call Task (parallel implementers)" to "spawn Task agents" and reframe the decision rule to lean toward calling Tasks: "Call Task agents for each module — unless the module is so tightly entangled with in-flight context that fully briefing an agent would cost more than implementing it directly. Default is Task; inline is the exception."
- The project's `build-pre-task.md` (pre-2026-04-27 version) has a cleaner Definition of Done with richer checklist language — specifically:
  - The Tests section asks "did any new public methods get added or changed?" rather than a flat bullet — this surfaces the question more reliably
  - The Track section includes "fill in ↑ source and → destination links before writing anything else — if you can't fill in the destination, the track isn't scoped" — this is a strong scoping guard that should be in the skill
  - The Commit grouping section uses stronger language: "If tests or docs are missing, do not commit the code alone. Either finish them or create a track step to complete them and note the gap explicitly."
- The skill's DoD is a condensed version that loses these nuances. Adopt the richer project language into the skill's Step 4.
- Add the Checklist Summary block (the four-item pre-commit checklist) from the project version — it's a useful at-a-glance gate that the skill's version is missing.
