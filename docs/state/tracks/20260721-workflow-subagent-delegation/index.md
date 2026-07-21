↑ [Shmorch Plan](../../plan.md)
→ `workflows/go.md`, `workflows/resume.md`, `workflows/wrap.md`, `workflows/self-improve.md`, `workflows/documentarian.md` (once shipped)

# Track: Workflow subagent delegation — rote, shmorch-specific steps off the main thread

**Status:** Open
**Opened:** 2026-07-21
**Domain:** Skill architecture / context budget

## Why

Surfaced 2026-07-21 while reviewing how much main-thread context Shmorch's own bookkeeping
consumes on every session — `go`/`resume` reading `context.md`/`stack.md`/`session.md`/
`plan.md` in full, `wrap` re-reading much of the same to write updates, `self-improve` and
`documentarian` doing broad scans — all of it competing with the actual project work for
the same context window. `core-breakup` (`tracks/20260601-core-breakup/`) attacks this by
shrinking what's loaded; this track attacks it a different way: **not loading it into the
main thread at all** for the parts of the job that are mechanical and shmorch-specific
rather than project-specific judgment calls.

## The idea

`go`, `resume`, and `wrap` follow a clear, largely deterministic path — read known files,
apply known rules, write known updates. That's a subagent's job, not the main thread's.
Same likely applies to `self-improve` and `documentarian`, which already spawn agents for
parts of their work.

- Run the rote portion as a subagent (Task tool / agent invocation).
- The subagent returns a **small, structured JSON package** — not prose, not raw file
  contents — sized to what the caller actually needs:
  - `go`/`resume`: richer — current focus, active track, pick-up-immediately note,
    proposed next moves (these drive what the user sees next, so the return payload
    carries real content)
  - `wrap`/`self-improve`/`documentarian`: thin — pass/fail, what was written, one-line
    summary (these are write-and-forget from the main thread's perspective; the main
    thread doesn't need the details, just confirmation + where to look if something's
    wrong)
- Main thread never reads `session.md`/`plan.md`/`stack.md` directly for these paths —
  it reads the subagent's structured summary instead. File-read cost is paid inside the
  subagent's own (disposable) context, not the session's.

## What this doesn't replace

- **Deterministic version/patch routines** for structural/rule changes (auto-update,
  VERSION bumps) stay deterministic — this track is about *where* rote work runs
  (subagent vs. main thread), not about replacing scripted mechanics with agent judgment
  where a script already does the job correctly. If a step is pure mechanics (bump a
  version string, append a log line), it should stay a `tools/*.sh` script, not become an
  agent call — agents are for the read-many-files-apply-known-rules-write-updates shape,
  not for things `sed`/`awk` already do deterministically.
- **Project-specific judgment** (what to build next, architectural tradeoffs) stays on the
  main thread — only the *shmorch bookkeeping* mechanics move.

## Open questions

- What's the JSON schema per workflow? Needs one shape for "rich" callers (go/resume) and
  one for "thin" callers (wrap/self-improve/documentarian) — probably a shared envelope
  (`{status, summary, ...workflow-specific fields}`) rather than one schema fits all.
- Subagent spawn cost (cold start, no memory of prior turns) vs. context savings — needs
  measuring on a real project, not assumed. Might only pay off for larger `session.md`/
  `plan.md` files, not every repo.
- How does this interact with the Catch-Up Wrap path in `go.md` (Step 3), which already
  does a fair amount of file reading/writing inline? That's exactly the kind of rote path
  this track would move off the main thread.

## Feasibility findings (2026-07-21)

Researched against Shmorch's own existing subagent doctrine (`agents/TASK-PROTOCOL.md`,
`core/portability.md`) and the current Claude Code tool surface, before building anything.
**Core idea holds, but three real constraints shape the design:**

**1. This cuts against Shmorch's own existing spawn gate — on purpose, and that's fine,
but the gate needs a second clause.** `TASK-PROTOCOL.md` currently says: spawn only when
*parallelizable*, *role-specific*, and *low file overlap with the current conversation* —
"when in doubt, do it yourself." `go`/`resume`/`wrap` are sequential and arguably one
persona ("session bookkeeper"), so they fail two of the three criteria as written. That
gate was written for parallel analysis work (analyst/architect/critic), not for
context-budget offloading. This track needs the gate to grow a distinct second path:
*spawn to keep large, ever-growing state files out of the main thread's context* — a
different justification than parallelism, but just as real (see the resume.md 25K-token
cap incident logged 2026-07-21 in `tracks/20260717-state-store-shape/`).

**2. No enforced JSON schema on the plain Agent tool — only on the separate Workflow
tool, which is gated behind explicit multi-agent opt-in.** Claude Code's `Agent` tool
returns free text (the subagent's final message) with no `schema` parameter — structured,
validated output only exists on the `Workflow` tool's `agent()` helper, and `Workflow` is
policy-gated to require the user explicitly opting into multi-agent orchestration
("ultracode", explicit ask, or a skill that calls it). Routine `go`/`resume`/`wrap` can't
freely reach for `Workflow` without conflicting with that gate. Practical path: extend
`TASK-PROTOCOL.md`'s existing `DONE: <path> | <summary> | <flags>` return convention to a
JSON line instead of pipe-delimited text, with the orchestrator parsing it and falling
back to treating the whole return as an error string if it doesn't parse. Convention, not
enforcement — same trust model the protocol already uses for `BLOCKER`/`CRUFT`/`GAP`.

**3. Must degrade to inline execution on non-Claude CLIs — no exceptions.**
`core/portability.md`'s "degrade gracefully" rule is absolute: every Claude-only
affordance (subagents included) needs a working inline fallback, since Codex, Cursor,
Gemini CLI, opencode, and Antigravity have no subagent primitive. This is actually easy
here — the JSON-return contract is CLI-agnostic; on a CLI without subagents, the *same
instance* runs the procedure inline and produces the same JSON shape internally instead of
receiving it from a spawned agent. The context-budget win is Claude-only, but correctness
isn't — the design doesn't fork behavior, only where the work executes.

**Net assessment:** the idea is sound and directly motivated by real incidents (PR #57,
the resume.md cap hit), not speculative. Two things need deciding before build: (a) revise
`TASK-PROTOCOL.md`'s spawn gate to add the context-budget justification as its own
criterion, not shoehorned into "role-specific"; (b) accept convention-based JSON (parsed,
not schema-enforced) rather than reaching for `Workflow`, since that tool's opt-in gate
exists specifically to prevent exactly this kind of default-on heavy orchestration.
Spawn-cost-vs-savings still needs real measurement (unchanged from the open question
below) — do it on this repo, since `session.md`/`plan.md` here are already large enough to
be a representative worst case.

## Related tracks

- `tracks/20260601-core-breakup/` — shrinks what's loaded into the main thread; this
  track removes some of it from the main thread's context entirely. Complementary, not
  competing — do core-breakup's trim regardless, since the subagent itself still pays
  read cost and smaller files are still better.
- `tracks/20260717-state-store-shape/` — subgraph-pull model for state; a structured
  JSON return from a workflow subagent is one plausible shape for "the subgraph," scoped
  per-workflow instead of per-query.
