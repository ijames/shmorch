---
status: Open
updated: 2026-08-11
summary: Branch B — the original idea in spec.md/findings.md, reframed as one of three swappable branches. Run go/resume/wrap's rote steps as subagents returning small JSON; main thread never opens the source files at all. One shared Python handler (tools/subcall.py) validates every workflow's sub-call, request and response, rather than per-workflow scripts. Highest ceiling, highest build cost, sequenced after A per findings.md.
---

↑ [index.md](index.md)
**In this section:** [Approach A — frontmatter-gated loading](approach-a-frontmatter-gating.md) · [Approach C — core/workflow doc JIT breakup](approach-c-core-doc-breakup.md) · [Comparison — which branch first](comparison.md) · [Findings — workflow subagent delegation](findings.md) · [Spec — workflow subagent delegation](spec.md)

# Approach B — subagent delegation

This is the track's original idea (2026-07-21) — full detail already lives in
[spec.md](spec.md) (the design) and [findings.md](findings.md) (simulation +
feasibility). This file exists so B stands next to A and C as one of three
directly-comparable branches, without duplicating that content.

## One-line summary

Run `go`/`resume`/`wrap`'s rote, shmorch-specific steps as a subagent call. The
subagent reads whatever files it needs in its own disposable context and returns a
small structured JSON package. The main thread never reads `session.md`/`plan/`/
`stack.md` directly for these paths — file-read cost moves off the main thread
entirely, not just off the "do I need to open this" decision (that's A) or off the
file's line count (that's C).

## Why it's a separate branch, not a modification of A

A and B attack different axes: A decides *which* files open, B decides *whose
context* pays for opening them. A file the orchestrator was always going to need
(`session.md`'s latest entry, `plan/`'s open items) still costs the same tokens to
read under A — A just stops it from opening the files it *didn't* need. B is the
lever that matters once A has already trimmed the "didn't need it" cost down to
near zero and there's still real, load-bearing read cost left over.

## Known blockers (from findings.md — restated here, not re-derived)

1. Cuts against `TASK-PROTOCOL.md`'s existing spawn gate (parallelizable /
   role-specific / low-overlap) — needs a second gate clause for
   context-budget-motivated spawns, since `go`/`resume`/`wrap` are sequential,
   single-persona work.
2. No enforced JSON schema on the plain `Agent` tool (only `Workflow`'s `agent()`
   has `schema`, and `Workflow` is opt-in-gated) — practical path is a convention
   (JSON line in the return, parsed with a text-error fallback), not
   schema-enforced structure.
3. Must degrade to inline execution on non-Claude CLIs with no subagent primitive
   — same JSON-shape contract, produced inline instead of received from a spawn.

None of these are fatal; all three are "design it this way," not "don't do this."

## The contract — one shared Python handler, Pydantic for validation, no LangGraph (2026-08-11, revised)

Split the original proposal into its two separate goals, per the 2026-08-10
discussion, then consolidated into a single reusable handler per the 2026-08-11
follow-up (instead of one bespoke script per workflow):

1. **"Enforce the JSON request/response structure"** — a validation problem.
   **Pydantic fits this well** and is kept in the design.
2. **"More deterministic injection to make the contract stronger"** — a
   determinism problem, not an orchestration problem. This does **not** need
   LangGraph — it needs the rote decision points *around* the subagent call
   (which files feed it, whether its return matches the expected shape) pulled
   out of LLM judgment and into a script, same principle as
   [Approach A's traversal script](approach-a-frontmatter-gating.md#traversal-as-tooling-not-llm-improvisation-2026-08-10).
   A graph-orchestration framework doesn't buy anything here that a validator
   script doesn't already provide — the "graph" in this workflow is one call
   in, one call out, not a multi-node pipeline.
3. **"Leveraged for all sub-calls"** (2026-08-11) — one handler shared across
   `go`/`resume`/`wrap`/`self-improve`/`documentarian`, not five near-duplicate
   validation scripts. `core/portability.md`'s Axis 1/Axis 2 split (added
   2026-08-11) is the doctrine home for this design; this section is the
   concrete build plan against that doctrine.

**Design — `tools/subcall.py`, one handler, three functions:**

- `prepare_request(workflow, args)` — validates outgoing task parameters against
  that workflow's Pydantic request model before they're embedded in the prompt
  handed to whichever tool call the CLI ends up making.
- `validate_response(workflow, raw_text)` — extracts and validates the returned
  JSON against the matching response model; on parse/validation failure, returns
  the raw text as an error string, never drops it silently — the same
  "parse or treat as error string" fallback `findings.md` already specified, now
  enforced by code instead of the orchestrating model eyeballing the shape.
- `capability(cli_name)` — looks up which spawn primitive (Axis 2 in
  `core/portability.md`) the current CLI has. A lookup table, not a decision:
  **the script cannot itself call another CLI's native subagent tool** — that
  call only exists inside the orchestrating agent's own tool-use loop. The
  handler tells the model what's available; the model still decides to spawn (or
  run inline) and makes the call itself. This boundary is load-bearing — don't
  let the design drift toward "the script dispatches the sub-call," it can't.

Models live in `agents/schemas/<workflow>_request.py` /
`agents/schemas/<workflow>_response.py` — one request/response pair per workflow,
Pydantic's model *is* the schema, no separately-maintained JSON Schema file to
drift out of sync. Two response envelope shapes per the original spec — rich
(`go`/`resume`) and thin (`wrap`/`self-improve`/`documentarian`) — implemented as
either a shared base model with per-workflow extra fields, or independent models
per workflow that happen to share a shape; decide once the first two are written
and the actual duplication (or lack of it) is visible.

**This is this skill's first Python dependency — flagged, not hidden, and now
formally an Axis 1 (environment-baseline) dependency per `core/portability.md`,
not a per-workflow exception.** Every other `tools/*.sh` script is bash with zero
install requirement beyond a POSIX shell; `tools/subcall.py` needs `python3` +
`pip install pydantic` present. What keeps this bounded rather than a slippery
slope toward "just use LangGraph too":

- **Scope stays narrow.** One script, three functions, all data-shape work
  (validate, don't decide, don't dispatch) — not a runtime the rest of the skill
  depends on. Same shape as every other `tools/*.sh` mechanic — callable,
  deterministic, replaceable — just written in Python because Pydantic is the
  right tool for "define a schema and validate against it," and shared across
  workflows because five copies of the same three functions is exactly the
  duplication `simplify`-style cleanup would flag later anyway.
- **Explicit fallback required by `core/portability.md` Axis 1.** If
  `python3`/`pydantic` isn't available, `tools/subcall.py` isn't callable — the
  orchestrator falls back to a plain inline structural check (do the required
  keys exist, are the types roughly right), same as before this design existed.
  Degraded, not broken.

## Branch identity

Suggested branch name if built standalone: `feat/<date>-workflow-subagent-delegation`.
Touches: `workflows/go.md`, `resume.md`, `wrap.md`, `self-improve.md`,
`documentarian.md` (return-JSON call sites), `agents/TASK-PROTOCOL.md` (gate + return
convention), `core/portability.md` (Axis 1/2 split, already landed 2026-08-11),
new `agents/schemas/*_request.py` / `*_response.py` (Pydantic models, rich + thin
envelopes), new `tools/subcall.py` (`prepare_request`/`validate_response`/
`capability`, + bash fallback path), `requirements.txt` or equivalent (first
Python dependency declaration in this repo).

## Backlinks

- [index.md](index.md)
- [spec.md](spec.md) — full design
- [findings.md](findings.md) — simulation + feasibility research
- [comparison.md](comparison.md) — how this stacks against A and C
