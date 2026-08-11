---
loads_when: pre-build 95%-confidence gate — deep tree-gated interview before any code change
size: 144 lines
---

# Workflow: interview

Deep, tree-gated interview: Project Focus & Shape, and Production Readiness (including
AI/LLM). Invoked by `commands/orient.md` for `/shmorch orient focus|readiness` — not part of
`workflows/orient.md`'s shallow Steps 0-7, and not invoked by `go`.

## Inputs
- Optional category argument (`focus` | `readiness`) — run both, Focus first then Readiness, if omitted
- `docs/project/context.md`, `docs/technology/architecture/observability.md`
- `docs/project/interview-log.md` (see "Recording answers")

## Roles
- None — runs inline

---

Re-runnable — unlike Context Setup (`workflows/orient.md` Step 1, one-time, fills-if-empty),
this updates existing answers rather than requiring a blank `context.md`.

If `docs/project/context.md` has a "Last reoriented" line, show it: "Last reoriented: <date>.
Answers below update what's already there — say 'skip' on any question to leave it as-is."

## Project Focus & Shape

Ask: "Want to revisit what this project is trying to become — scope, audience, shape? (yes / skip)"

If yes, ask ONE at a time, allowing "skip" on any individual question:
- "What does success look like for this project, in one sentence?"
- "Who is this for — just you, a team, the public?"
- "What's explicitly out of scope right now — the anti-decisions?"
- "Any hard constraints — deadline, budget, must-integrate-with-X?"

Write answers to `docs/project/context.md` under a `## Project Focus & Shape` heading —
create it if missing, update the existing bullets in place if present. Do not duplicate a
bullet that's unchanged. Record each answer per "Recording answers" below.

## Production Readiness

Modeled on Google's SRE Production Readiness Review, scoped down to the categories that
matter for a small/solo project — not the full enterprise checklist.

Assumed relevant for every project unless the user explicitly opts out — say once: "Walking
through production-readiness questions now — monitoring, security, backups, cost, on-call,
and AI/LLM if this project touches one. Say 'skip' on any area or question, or 'skip all' to
opt out entirely." No blanket yes/no gate; go straight into each area's own gate question, and
only ask the follow-up if the gate answer signals it's relevant.

**Monitoring & alerting** — Gate: "Does anything here need alerting when it breaks — errors,
traffic spikes, unpaid bills?" If yes: "Where should alerts go — Zulip, email, nowhere set up yet?"

**Security** — Gate: "Any auth, PII, or compliance requirements right now?" If yes: "What's
the sensitive surface — user data, payments, internal only?"

**Backup / disaster recovery** — Gate: "Is any data here irreplaceable, or is everything
reproducible from source/config?" If irreplaceable: "Is it backed up anywhere today?"

**Cost / capacity** — Gate: "Any cost ceiling or scaling concern worth flagging now?" If yes:
"What's the ceiling, and what happens if it's hit?"

**On-call / escalation** — Gate: "If this breaks at 2am, does it need to wake someone up, or
can it wait till morning?" If wake-someone-up: "Who, and how — Zulip, phone, other?"

**AI/LLM development & product integration** — based on Google's ML Test Score (data/model/
infra/monitoring rubric for ML production readiness) and NIST's AI Risk Management Framework
(Govern/Map/Measure/Manage), scoped to how deep the user wants to go — this area is broader
and more variable than the other four, so depth is explicitly the user's call, not fixed.

Gate: "Does this project develop or integrate an AI/LLM component — either in the product
itself, or as part of how it's built? (no / yes, quick pass / yes, full rubric)"

If no: skip the rest of this area.

If yes, first ask the exposure question — this scopes both this interview and the standing
build-time guardrail described below, so don't skip it even on a quick pass: "What's the
exposure — public/user-facing input reaches the model, internal-only/trusted input, or
agentic (the model can take actions/call tools)?"

Quick pass — one question: "Anything already in place for eval/quality checks, cost or usage
telemetry, or a rollback plan if a model update regresses behavior? (or 'nothing yet')"

Full rubric — ask each, one at a time, "skip" allowed:
- **Data** (ML Test Score) — "Is training/eval/fine-tuning data versioned and its provenance known, or is this using a stock model with no custom data?"
- **Model** (ML Test Score) — "Is there an eval/benchmark run before a new model version ships, and a rollback plan if it regresses?"
- **Infra** (ML Test Score) — "What's the fallback if the model provider has an outage or rate-limits you — degrade, queue, or hard-fail?"
- **Monitoring** (ML Test Score) — "Is anything tracking drift, output-quality regression, or token/cost usage over time?"
- **Governance** (NIST AI RMF) — "Who owns the call if the model does something wrong in production — is that decided, or TBD?"

Do not ask about specific attack vectors (prompt injection, jailbreaks, etc.) here — that's
OWASP Top 10 for LLM Applications territory, and it's applied as a standing build-time
guardrail scaled to the exposure level just captured (`workflows/design.md`,
`agents/roles/critic.md`), not an interview topic. The working assumption is that no
AI/LLM-integrated system ships with a known OWASP LLM Top 10 vulnerability, regardless of
whether the user brings it up here.

Write answers to `docs/technology/architecture/observability.md` under a `## Production
Readiness` heading, one sub-heading per area answered (same update-in-place rule) — this file
already exists for exactly this purpose ("fill before going to prod"); infrastructure is a
topic inside `architecture/`, not a separate sibling directory (see
`docs/technology/architecture/index.md`). Skip writing anything for an area the user skipped
entirely. Record each answer per "Recording answers" below.

## Stamp and hand back

Update (or add) the "Last reoriented: YYYY-MM-DD" line in `docs/project/context.md`.
Summarize what changed in 2-3 sentences.

---

## Recording answers to `docs/project/interview-log.md`

Applies to Context Setup (`workflows/orient.md` Step 1) and this Deep interview — not to every
routine orientation. One small append-only file; do not let it grow into a database.

Before writing a new answer:
1. `grep` the log's tail for the same question text. If a prior answer exists and differs
   from the new one, that's a **contradiction (old vs new)**.
2. Grep `docs/{product,technology}/decisions/` (topic-appropriate) for a standing decision the
   new answer conflicts with (e.g. answer says "no auth needed" but a decision entry records
   OAuth was added). That's a **contradiction (answer vs built system)**.

On either hit: surface it to the user inline before finalizing — "This contradicts what you
said on <date>" or "...contradicts decision <date>/<title> — intentional change, or should I
leave the prior answer?" — then record their resolution.

Append one entry per answered question to `docs/project/interview-log.md` (create with a
one-line header if missing):

```
## YYYY-MM-DD — <Context Setup | Focus & Shape | Production Readiness: <area>>
**Q:** <question>
**A:** <answer>
**Discrepancies:** none
```

Or, when a contradiction was found:

```
**Discrepancies:** contradicts YYYY-MM-DD answer "<old answer>" — <user's resolution>
```

This is what lets Shmorch keep a project's goals and scope intentional rather than
accidental — changes get surfaced and chosen, not silently drifted into. Related but
distinct from `docs/project/plan/prompt-goal-alignment-scope-monitor.md` (a per-prompt
live-work scope-drift check, not an interview-answer check) — cross-link, don't conflate.
