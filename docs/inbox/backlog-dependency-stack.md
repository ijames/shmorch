↑ [Inbox](index.md)
**In this section:** [build.md — Task agent protocol: loosen spawn decision, adopt richer DoD language](build-md-task-agent-protocol.md) · [Stub tracks on separate branches collide on shared index/plan files](stub-tracks-shared-file-collision.md) · [Merge strategy default (never squash) — and a process gap in how this was almost added](never-squash-merge-and-cross-repo-discipline.md)

# Backlog may be better modeled as a dependency stack than a flat list

**Issue (2026-05-07):** When work items block each other (e.g. equity-factory → order-price-gherkin), a flat domain list doesn't surface the push/pop relationship. The developer had to mentally track "do this first" without structural support.

**What to consider:**
- plan.md's backlog could have a formal "Active Stack" section at the top where blocked chains are pushed and popped in dependency order, separate from the flat domain inventory below.
- This is a LIFO model for the hot path: top of stack = do next; bottom = not yet unblocked.
- Relates to the Beads/Conductor evaluation already in the backlog — a proper dependency graph tool would make this structural rather than prose.
- Very loose for now — worth revisiting if dependency chains become common.
