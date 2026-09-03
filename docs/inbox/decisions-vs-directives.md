# Decision logs are passive history; behavior-affecting decisions need active codification

**Filed from:** shmorch (self), 2026-09-01

## Observation

The user drew a distinction Shmorch's docs doctrine doesn't currently make explicit:

- **Decisions** (`product/decisions/`, `technology/decisions/`) are a static, chronological
  record. Entries are never removed; a superseded decision gets a correction note, not a
  rewrite. This is a log — read only when someone is deliberately looking at decision
  history, not loaded during normal operation.
- **Directives** — a decision that actually changes workflow behavior, role behavior, or
  code functionality — aren't satisfied by existing in the decision log. Until the
  decision's intent is codified into the *active* context (a workflow file, `core/`,
  `agents/`, or the code itself), it has no effect. A decision sitting only in the log is
  inert.
- The user's claim: "decisions generally aren't" codified — i.e. the log is being treated
  as if writing the entry were the whole job, when for behavior-affecting decisions it's
  only half of it.
- Active documentation nodes (workflows, core files) should *link back* to the relevant
  decision-log entry rather than restate its rationale — so the decision's context can be
  pulled into the agent's window narrowly, on demand, instead of ballooning the active file.

## Existing conflict this surfaces

`core/documentation.md` §"Decisions index growth" currently says a split-out topic file
"states only the *current* form of each decision, never the history of how it was reached
or revised — collapse correction chains into one clean statement," pointing to git log as
the audit trail instead.

That's in tension with `templates/docs/product/decisions/index.md`, which says "Entries
are never removed; add a correction note if a decision is later reversed" — and with the
chronological-log model the user is describing here. Whoever picks this up should reconcile
the two: either the topic-file split is meant to compact history (git remains the record)
while the pre-split `index.md` stays chronological, or the doctrine needs to say so
explicitly instead of leaving both rules to coexist unreconciled.

## Proposed follow-up (not done)

1. Reconcile the "collapse correction chains" line with the chronological/correction-note
   model — decide whether topic-file splitting is allowed to compact history or not, and
   say so in one place.
2. Add the decision-vs-directive distinction to `core/documentation.md`'s Decisions
   section: a decision that changes workflow/role/code behavior isn't done until an active
   node (workflow, `core/`, `agents/`) is updated to carry it out, ideally linking back to
   the decision-log entry rather than re-deriving its rationale inline.
3. Possibly add a check (documentarian? track-close checklist?) that flags a new
   decisions-log entry which never got a corresponding edit to any active file, when its
   content implies one should exist.
