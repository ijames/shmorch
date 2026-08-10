# Workflow: reorient

Adaptive, tree-structured interview: two top-level categories, each gated by
one high-level question before any sub-questions are asked. Unlike orient's
Context Setup (`workflows/orient.md` Step 1 — one-time, fills-if-empty),
reorient is meant to be re-run — it updates existing answers rather than
requiring a blank `context.md`.

## Inputs
- Optional category argument (`focus` | `readiness`) — jumps straight to that
  branch instead of walking both
- `docs/project/context.md`
- `docs/technology/architecture/observability.md`

## Roles
- None — runs inline

---

## Step 0 — Scope

If an argument was given, run only that category's tree (Step 1 for `focus`,
Step 2 for `readiness`). Otherwise run both, Focus first then Readiness.

If `docs/project/context.md` has a "Last reoriented" line, show it: "Last
reoriented: <date>. Answers below update what's already there — say 'skip' on
any question to leave it as-is."

---

## Step 1 — Project Focus & Shape (gate)

Ask: "Want to revisit what this project is trying to become — scope,
audience, shape? (yes / skip)"

If skip: go to Step 2 (or Step 3 if this was a `focus`-only run).

If yes, ask ONE at a time, allowing "skip" on any individual question:
- "What does success look like for this project, in one sentence?"
- "Who is this for — just you, a team, the public?"
- "What's explicitly out of scope right now — the anti-decisions?"
- "Any hard constraints — deadline, budget, must-integrate-with-X?"

Write answers to `docs/project/context.md` under a `## Project Focus & Shape`
heading — create it if missing, update the existing bullets in place if
present. Do not duplicate a bullet that's unchanged.

---

## Step 2 — Production Readiness (gate, tree-structured)

Modeled on Google's SRE Production Readiness Review, scoped down to the
categories that matter for a small/solo project — not the full enterprise
checklist. This step exists because `orient.md`'s one-time interview never
asks anything from this list, and most projects never get asked at all.

Ask: "Want to go through production-readiness questions — monitoring,
security, backups, cost, on-call? (yes / skip / name specific areas:
monitoring, security, backup, cost, oncall)"

If skip: go to Step 3.

For each selected area (all five, if the user said "yes" with no specifics),
ask its gate question first. Only ask the follow-up if the gate answer
signals it's relevant — don't force every sub-question on a project that
clearly doesn't need it yet.

**Monitoring & alerting**
Gate: "Does anything here need alerting when it breaks — errors, traffic
spikes, unpaid bills?"
If yes: "Where should alerts go — Zulip, email, nowhere set up yet?"

**Security**
Gate: "Any auth, PII, or compliance requirements right now?"
If yes: "What's the sensitive surface — user data, payments, internal only?"

**Backup / disaster recovery**
Gate: "Is any data here irreplaceable, or is everything reproducible from
source/config?"
If irreplaceable: "Is it backed up anywhere today?"

**Cost / capacity**
Gate: "Any cost ceiling or scaling concern worth flagging now?"
If yes: "What's the ceiling, and what happens if it's hit?"

**On-call / escalation**
Gate: "If this breaks at 2am, does it need to wake someone up, or can it wait
till morning?"
If wake-someone-up: "Who, and how — Zulip, phone, other?"

Write answers to `docs/technology/architecture/observability.md` under a
`## Production Readiness` heading, one sub-heading per area answered (same
update-in-place rule as Step 1) — this file already exists for exactly this
purpose ("fill before going to prod"); infrastructure is a topic inside
`architecture/`, not a separate sibling directory (see
`docs/technology/architecture/index.md`). Skip writing anything for an area
the user skipped entirely — an absent sub-heading means "not yet assessed,"
not "not needed."

---

## Step 3 — Stamp and hand back

Update (or add) the "Last reoriented: YYYY-MM-DD" line in
`docs/project/context.md`.

Summarize what changed in 2-3 sentences. If this ran standalone
(`/shmorch reorient`), stop here. If it ran as part of another flow, hand
back to that flow.
