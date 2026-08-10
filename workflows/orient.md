# Workflow: orient

The orientation phase — read state, surface gaps, propose the next move. Runs after
provisioning (or directly, when the repo is already current). Invoked by `workflows/go.md`
with no argument (shallow path, Steps 0-7), and directly by the user via `/shmorch orient`
(same shallow path) or `/shmorch orient focus|readiness` (skips straight to the deep,
tree-gated interview in "Deep interview" below — no Steps 0-7).

## Inputs
- Optional argument: none (shallow, default) | `focus` | `readiness` — selects deep-interview
  category when run directly; ignored (always shallow) when invoked by `go`
- Standard state files: `docs/project/context.md`, `docs/project/stack.md`, `docs/project/session.md`, `docs/project/plan/`
- `docs/project/interview-log.md` (deep interview and Context Setup only — see "Recording answers")

## Roles
- None — runs inline

## Orientation is shallow — no code until a directive

Read **only** `docs/project/*` (context, stack, session, plan) and git status/log metadata. Do **not** open, read, `grep`, or analyze source code, and do **not** spawn discovery/analyst agents, during orientation. Reading code is the Analyze / Build phase (or `discover`) — it begins only after the user answers your proposal with a directive. If a good next move needs code investigation, *offer* it ("want me to analyze X?") instead of doing it now.

---

## Step 0 — Pulse check

If `docs/project/index.md` exists, read it first — the front-matter `summary` lines (see
`core/documentation.md` § Front-Matter Previews) give a cheap overview of what's changed
before opening the full files in Steps 1–3. If it's missing, skip straight to Step 1 (older
projects may not have it yet — not an error).

---

## Step 1 — Read context and stack

Read `docs/project/context.md` and `docs/project/stack.md` in parallel.

If `stack.md` is missing or empty, note it: "Stack inventory hasn't been filled in yet — I'll build it up as we work, or you can run `/shmorch vacuum` to kick off a stack analysis."

If `context.md` is unfilled, run the Context Setup flow:
1. "Before we start, a few quick questions."
2. Ask ONE at a time:
   - "What is this project? One or two sentences."
   - "What's your tech stack? ('not sure yet' is fine)"
   - "Existing codebase or starting fresh?"
   - "PR merge strategy: merge, squash, or rebase? (merge preserves branch topology in git graph; squash = one commit per PR; rebase = linear history, no merge commits)"
   - "Enable the docs-placement reminder right after each docs file is written? (flags possible wrong skeleton location while it's fresh, not batched at session end — off by default)"
   - "Anything I should never do without asking first?"
3. Write answers to `docs/project/context.md`, the merge strategy to `.shmorch/AGENTS.md` under Branching Discipline, and the docs-placement choice to `.shmorch/AGENTS.md` under Docs Placement Hook `**Status:**`, confirm with user. Record each answer per "Recording answers" below.

If filled, summarize in 1-2 sentences.

This Context Setup interview stays intentionally minimal (fast first
contact). For deeper, re-runnable project-focus or production-readiness
questions (Google SRE PRR-based, tree-gated by category), the user can run
`/shmorch orient focus` or `/shmorch orient readiness` any time — see "Deep
interview" below, not part of this shallow flow.

---

## Step 2 — Read last session

`session.md` grows without bound across a project's life — do not `Read` the whole file. Extract only the most recent entry (from the top `## Latest Session` heading down to the next `---` or `##`):

```bash
awk '/^## (Latest Session|[0-9]{4}-[0-9]{2}-[0-9]{2})/{n++} n==1{print} n==2{exit}' docs/project/session.md
```

Summarize what happened last time in 1-2 sentences. Only read further back in the file if the user asks about history older than the last session, or if the current entry references something unresolved from an earlier one by name.

---

## Step 3 — Read plan

Read `docs/project/plan/`. Show the active tracks table and current focus.

---

## Step 4 — Check for leftover work

Run `git status` and `git log --oneline -5` in parallel. Then:

1. If there are uncommitted changes, mention it upfront:
   > "There are uncommitted changes from last time — want to commit those first, or continue and commit later?"
   If the working tree is clean, skip this without comment.

2. Compare `git log --oneline -5` against the "Commits" list in session.md. If the recent commits already match what session.md records as done last session, note this internally and skip re-committing those items. This prevents duplicate commits after context window splits.

---

## Step 5 — Untracked test failures check

Scan `docs/project/session.md` for lines containing `failing`, `outstanding`, `pre-existing`, or `test failure` (case-insensitive):

```bash
grep -i "failing\|outstanding\|pre-existing\|test failure" docs/project/session.md | head -10
```

For each failure cluster found:
1. Check `docs/project/plan/` — is there already a backlog item tracking it?
2. If **no plan item exists**: add one immediately as a new file in `docs/project/plan/` (slug from the title, e.g. `fix-pre-existing-test-failures-<area>.md`):
   ```
   ---
   status: open
   category: Fixes
   ---

   **Fix pre-existing test failures: <component/area>** — <N> failures, tracked <YYYY-MM-DD>
   ```
3. Surface to the user briefly: "Found <N> pre-existing test failures in <area> with no plan item. Added to backlog."

Do not surface this step unless failures are found. A failure with no plan item is invisible to sprint planning and violates the always-red rule.

---

## Step 6 — Memory staleness check

Scan the CLI's external memory for this project (e.g. Claude `~/.claude/projects/.../memory/`, omp `memory://`) for any entries containing `UNFIXED`, `OPEN QUESTION`, `TWO BUGS`, or `BUG` (case-insensitive). For each match found:

1. Note what the memory claims
2. Run `git log --oneline -10` and `git grep` to check if the claim is still current
3. If evidence suggests the memory is stale, update or remove it before relying on it

Skip silently if no matches found. Do not surface this step to the user unless a stale memory is found — in that case, note the correction briefly.

Pattern that triggered this rule: a session consumed a full task cycle verifying a bug that memory marked "UNFIXED" but git log showed was already fixed two sessions earlier.

---

## Step 7 — Surface gaps and propose next move

Before asking what to work on, scan for obvious gaps and surface them:
- Are there unfilled placeholders in `context.md` (code style, test framework, commit style)?
- Is `stack.md` missing key dependency versions?
- Does `session.md` note specific things to pick up immediately?

If the session.md has a "Pick up immediately" note, lead with that — do it or propose it before asking the open-ended question.

Then propose 2-3 concrete options for what to do next, based on the plan and any gaps found. Don't just ask "what do you want to work on?" cold — give the user something to react to.

If the user declines all options or says "not yet", ask what's holding them back, or offer something smaller (a quick scan, filling in state, answering a codebase question). Never just go quiet.

---

## Deep interview — Focus & Readiness (on-demand, `/shmorch orient focus|readiness`)

Adaptive, tree-structured: two categories, each gated by one high-level question before any
sub-questions are asked. Unlike Context Setup above (one-time, fills-if-empty), this is meant
to be re-run — it updates existing answers rather than requiring a blank `context.md`. Skips
Steps 0-7 entirely when entered this way.

If `docs/project/context.md` has a "Last reoriented" line, show it: "Last reoriented: <date>.
Answers below update what's already there — say 'skip' on any question to leave it as-is."

If no argument (`focus` or `readiness`) was given, run both, Focus first then Readiness.

### Project Focus & Shape

Ask: "Want to revisit what this project is trying to become — scope, audience, shape? (yes / skip)"

If yes, ask ONE at a time, allowing "skip" on any individual question:
- "What does success look like for this project, in one sentence?"
- "Who is this for — just you, a team, the public?"
- "What's explicitly out of scope right now — the anti-decisions?"
- "Any hard constraints — deadline, budget, must-integrate-with-X?"

Write answers to `docs/project/context.md` under a `## Project Focus & Shape` heading —
create it if missing, update the existing bullets in place if present. Do not duplicate a
bullet that's unchanged. Record each answer per "Recording answers" below.

### Production Readiness

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

### Stamp and hand back

Update (or add) the "Last reoriented: YYYY-MM-DD" line in `docs/project/context.md`.
Summarize what changed in 2-3 sentences.

---

## Recording answers to `docs/project/interview-log.md`

Applies to Context Setup and the Deep interview (Focus & Readiness) above — not to every
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

---

## Working with Tracks

Active tracks live in `docs/project/tracks/`. Each has index.md, spec.md, plan.md.

When starting work on a track:
1. Read the track's spec and plan
2. Stamp: `bash "$SHMORCH_HOME/tools/timelog.sh" "TASK_START" "track name"`
3. Update `docs/project/plan/` status to "In progress"
4. Do the work
5. Stamp: `bash "$SHMORCH_HOME/tools/timelog.sh" "TASK_DONE" "track name"`

## Workflow Phases

| Phase | File | When |
|---|---|---|
| Intake | `.shmorch/workflows/intake.md` | New conversation, unclear goal |
| Analyze | `.shmorch/workflows/analyze.md` | Existing code to examine |
| Spec | `.shmorch/workflows/spec.md` | Define what to build |
| Design | `.shmorch/workflows/design.md` | Architecture before code |
| Build | `.shmorch/workflows/build.md` | Time to code |
| Vacuum | `.shmorch/workflows/vacuum.md` | After build or on demand |

Read the workflow file before starting each phase.
Resolution order: `.shmorch/workflows/<name>.md` (project override) → `$SHMORCH_HOME/workflows/<name>.md` (skill default).

## When work is done for the day

Suggest this sequence naturally — don't wait for the user to ask:

1. **Vacuum** — `/shmorch vacuum` to catch TODOs, dead code, empty tests before committing
2. **Commit** — `/shmorch commit` to group and commit changes cleanly
3. **Wrap** — `/shmorch wrap` to close the session and update state

You don't have to do all three every time. After a small change, commit + wrap is enough. After a big build, vacuum first.

## Stack Awareness

Before recommending any package, upgrade, pattern, or API:
1. Check `docs/project/stack.md` — is there a version constraint that rules this out?
2. If the stack has external constraints (hosting platform, client environment, API compatibility), respect them without asking the user to re-explain them every session
3. If you discover a new constraint during work (e.g. a package can't be upgraded because of a transitive dependency), add it to `stack.md` immediately
4. The "Upgrade Opportunities" section in `stack.md` is where good ideas go when they can't be acted on yet — log them there, not as inline TODOs

## Architecture Decisions

When a significant decision is made, append to `docs/{product,technology}/decisions/ (topic-appropriate)`:

```markdown
### [YYYY-MM-DD] Decision title
**Context:** Why this needed deciding
**Decision:** What was decided
**Rationale:** Why
```

Identity, timing events, and safety rules are always loaded from `shmorch-core.md` — not repeated here.
