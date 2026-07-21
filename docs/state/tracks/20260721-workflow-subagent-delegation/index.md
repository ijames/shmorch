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

## Related tracks

- `tracks/20260601-core-breakup/` — shrinks what's loaded into the main thread; this
  track removes some of it from the main thread's context entirely. Complementary, not
  competing — do core-breakup's trim regardless, since the subagent itself still pays
  read cost and smaller files are still better.
- `tracks/20260717-state-store-shape/` — subgraph-pull model for state; a structured
  JSON return from a workflow subagent is one plausible shape for "the subgraph," scoped
  per-workflow instead of per-query.
