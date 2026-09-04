---
loads_when: burning down the personal-profile session backlog in a capped, cheap-tier batch
size: 115 lines
---

# Workflow: personal-eval (pe)

Runs the pipeline documented in `~/.shmorch/personal-profile/README.md` § Pipeline,
in a small, cost-capped batch, on a cheap model tier. This workflow is the
*orchestration* only — the taxonomy and extraction scripts stay in `personal-profile`
because that repo is deliberately private; shmorch itself is public. The two roles it
drives, `pe-summarizer` and `pe-synthesizer`, live in `$SHMORCH_HOME/agents/roles/` —
they're generic pipeline mechanics (read a transcript, classify against a taxonomy),
not private data, so they belong in the public skill like every other role.

## Why this exists

The pipeline was designed one-session-at-a-time on purpose (cheap, resumable,
interruptible). Running it manually against the whole backlog in one go — asking for
"10 sessions at a time" straight from shmorch on a strong model — burned far more
tokens than the design intends. This workflow puts a hard batch cap, an explicit
cheap-model reminder, and a small-number-first default back in front of that
temptation, without losing the batch convenience.

## When to use
- On demand via `/shmorch personal-eval` or `/shmorch pe`
- Never automatically — no hook, no wrap-time trigger. Backlog burn-down is a
  deliberate, cost-aware action the user takes, not ambient behavior.

## Inputs
- `$PERSONAL_PROFILE_HOME` (default `~/.shmorch/personal-profile`) — resolve once,
  same pattern as `$SHMORCH_HOME` (`core/portability.md`): env var wins, else the
  conventional path.
- `$PERSONAL_PROFILE_HOME/processed.log` — backlog ledger

## Roles
- `agents/roles/pe-summarizer.md` — Model tier: **default/strong** (Claude `sonnet`,
  omp `default`), not cheap. A 2026-09-04 live test found `haiku` inverting
  `[James]`/`[Agent]` speaker attribution on most bullets of a real session; a
  `sonnet`-tier re-run of the same session got every bullet right. Speaker
  attribution across a mixed assistant/user transcript isn't the fixed-format
  extraction this tier split originally assumed — treat it as reasoning, not lookup.
- `agents/roles/pe-synthesizer.md` — Model tier: **cheap** (Claude `haiku`, omp
  `smol`), unaffected by the above — folding an already-tagged summary into section
  files is the fixed-format part.
- `agents/roles/pe-analyzer.md` — used only by the `pe analyze` path (Step A below),
  not the scan pipeline. Model tier: **strong** (Claude `opus`/strong `sonnet`, omp
  `slow`) — deliberately the opposite tier from the scan roles above, since this is
  open-ended interpretive reasoning over the accumulated profile, not fixed-taxonomy
  extraction.

---

> Read `agents/TASK-PROTOCOL.md` and `core/portability.md` § Capability adapter matrix
> before spawning anything — model tiers and the subagent call are CLI-neutral, map
> per this session's CLI.

---

## Step 0 — Dispatch: scan vs. analyze

Check the invocation before Step 1. If the args are (or contain) the word `analyze`
(`pe analyze`), skip the scan pipeline (Steps 1–4) entirely and go to Step A below.
Everything else — bare `pe`, `pe scan <N>`, `pe <N>`, natural-language session counts
— is the scan path and continues at Step 1 as written.

---

## Step 1 — Resolve `$PERSONAL_PROFILE_HOME` and check the backlog

```bash
PERSONAL_PROFILE_HOME="${PERSONAL_PROFILE_HOME:-$HOME/.shmorch/personal-profile}"
python3 "$PERSONAL_PROFILE_HOME/tools/scan.py"
```

Prints unprocessed sessions, oldest first. If empty, say so and stop — nothing to do.

---

## Step 2 — Parse the invocation, decide N

Arguments arrive as whatever followed `pe` — dispatch on them, not on a fixed flag
syntax, since natural phrasing ("scan two sessions") is a valid invocation too:

- **Bare `pe`** (no number found in the args) — report the backlog count from Step 1,
  then ask: "N unprocessed. How many should I scan?" Do not guess a default and run;
  wait for the answer. This is the "just catching up" path.
- **`pe scan <N>`**, **`pe <N>`**, or a number spelled out in the sentence
  ("scan two sessions", "the last couple of sessions" → 2) — extract N and skip
  straight to Step 3 with that count. Still say the reminder in Step 2.5 before
  running; don't skip it just because N was given inline.
- **N above the backlog count** — clamp to the backlog count, say so.
- **N above 10** — this is the cap this workflow exists to enforce. Refuse the number
  as given; ask the user to confirm running in multiple smaller batches instead, or
  explicitly override once with a stated reason. Never silently clamp a
  larger-than-10 request the way you'd clamp an over-the-backlog one — a user asking
  for 25 needs to hear the cap exists, not have it quietly reduced.

---

## Step 2.5 — Mixed-tier reminder

Before running anything, state plainly: "Running N sessions — summarizer on
default/strong tier (`sonnet`, not `haiku`/`smol`; attribution needs it), synthesizer
on cheap tier (`haiku`/`smol`). If your current CLI session is on a different model,
the subagent calls below still pin to their own tier regardless — but if you're about
to run either role inline on a no-subagent CLI (Axis 2 fallback), switch your own
session to match that role's tier first, since there's no subagent call to pin it for
you there."

---

## Step 3 — Per-session extraction (one subagent per session, not one agent for the batch)

For each of the N sessions, **in sequence, not parallel** — the synthesizer step
writes to shared section files and commits after each session; concurrent
writes would race:

1. `python3 "$PERSONAL_PROFILE_HOME/tools/session_turns.py" <path>` — clean request/response
   text for that session.
2. Spawn (or run inline on CLIs without subagents — `core/portability.md` Axis 2) a
   **pe-summarizer** agent, default/strong tier, role
   `$SHMORCH_HOME/agents/roles/pe-summarizer.md`, input the Step 3.1 output. Writes
   `$PERSONAL_PROFILE_HOME/sessions/<slug>.md`.
3. Spawn (or run inline) a **pe-synthesizer** agent, cheap tier, role
   `$SHMORCH_HOME/agents/roles/pe-synthesizer.md`, input the new `sessions/<slug>.md`
   plus the raw text from 3.1. Updates the matching section file(s) and
   `profile/index.md` if stale, commits, and runs `tools/scan.py --mark <path>`.
4. Append a row to `stats.md` (session, date, project, start–end, duration, categories
   touched) and update its tally counts — same pass as `processed.log`, per the README.

---

## Step 4 — Report

After the batch, report to the user: sessions processed, categories touched, backlog
remaining (`python3 tools/scan.py` count), and any `AMBIGUOUS:` lines emitted by this
batch's synthesizer runs (see `pe-synthesizer.md`'s MECE overflow rule) — surface the
count and file, don't let it go unnoticed in a routine commit. Do not start another
batch automatically — the user re-runs `/shmorch pe` when ready for the next one.

---

## Step A — `pe analyze`: strong-tier interpretive pass

A separate mode from Steps 1–4: reads the whole accumulated profile and writes one
dated analysis document. Does not touch the section files, `sessions/`, `stats.md`,
or `processed.log` — read-only against all of them.

1. Resolve `$PERSONAL_PROFILE_HOME` (same as Step 1). Confirm
   `$PERSONAL_PROFILE_HOME/profile/index.md` exists; if the profile is empty or
   near-empty (check `stats.md` tallies), say so and stop — nothing to analyze yet.
2. State plainly: "Running `pe analyze` on the strong tier (`opus`/strong `sonnet` —
   never `haiku`/cheap for this) — this is a slower, more expensive pass than a scan
   batch, by design."
3. Spawn (or run inline on no-subagent CLIs) a single **pe-analyzer** agent, strong
   tier, role `$SHMORCH_HOME/agents/roles/pe-analyzer.md`. No per-item loop, no
   parallel agents — one agent reading the whole profile is the entire step.
4. Report the output path (`analysis/<date>-analysis.md`) and the agent's one-sentence
   takeaway to the user. Do not auto-open or summarize the full document beyond that
   — the user reads it themselves.

---

## Cross-CLI note

Everything above already reads CLI-neutrally per `core/portability.md`: the shell
commands are identical everywhere; only the agent-spawn call in Step 3.2/3.3 differs
(Claude `Agent`, omp/Pi `task`, no-subagent CLIs run the role inline). Nothing here is
Claude-specific — this is why the workflow lives in `$SHMORCH_HOME/workflows/`
instead of being hand-run only from Claude Code.

---

## Deferred — scanning other agents' logs, not built here

The current pipeline is Claude Code transcripts only
(`~/.claude/projects/**/*.jsonl`, per `$PERSONAL_PROFILE_HOME/README.md` § Source).
Extending `pe` to also fold in other orchestrators' session logs (omp, opencode,
whatever else the user runs) or other personal-reflection tools/logs is a real future
direction, but each source needs its own extraction path (different log format,
different transcript shape) — not a one-line addition to this workflow. Parking this
as a named future project rather than folding it into the current build; see
`docs/project/pre-planning.md` for where speculative scope like this gets tracked.
