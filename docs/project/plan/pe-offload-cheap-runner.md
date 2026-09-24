---
priority: 3
status: open
category: Features
---

↑ [Plan](index.md)
**In this section:** [backfill-migrate-claude-project-memory](backfill-migrate-claude-project-memory.md) · [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [doctrine-load-verification](doctrine-load-verification.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [template-content-genericity-detection](template-content-genericity-detection.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

# `pe` off Anthropic: a scripted daily runner on cheap OpenRouter models

Asked for 2026-09-24: run `/shmorch pe` regularly, even from a daily cron, without using up
Anthropic tokens. The target is ≤10% of today's cost. This plan aims for about 1–2%.

## Where the cost actually goes today

Measured 2026-09-24 against `~/.shmorch/personal-profile`:

- **Backlog:** 143 unprocessed sessions out of 199.
- **Session size after `session_turns.py`** (sample of 40): median ~19 KB (≈5k tokens), p90
  ~166 KB (≈42k tokens), max ~960 KB (≈240k tokens), mean ≈21k tokens.
- **Profile:** 250 KB across 13 section files. `track-record.md` alone is 100 KB (≈25k
  tokens) and gets read on nearly every session.

The transcript isn't the expensive part. The **agent loop** is. Every session gets two
Claude Code subagents, and each one:

1. carries 15–20k tokens of system prompt and tool schemas before it reads anything;
2. resends its whole context on every tool call (read the role, read the transcript, read
   index.md, read each section, write, `git commit` ×3, `scan.py --mark`), so 6–10 turns
   multiply everything by 6–10×;
3. makes the synthesizer re-read the raw transcript *and* rewrite whole section files as
   output tokens.

Rough cost per mean session at API prices: ~200k input tokens for the Sonnet summarizer plus
~750k for the Haiku synthesizer ≈ **$1+ per session**, or ~$150 for the backlog. On a
subscription, that's the rate-limit drain.

## Design: code does the dull work, a model makes one call per judgment

Replace the two agents with a **Python runner** (`tools/pe_runner.py` in `$SHMORCH_HOME`,
stdlib only, `urllib` against OpenRouter's OpenAI-compatible `/chat/completions`). Code does
every file read, file write, git step and ledger update. A model gets **one stateless call**
per judgment step: JSON in, JSON out, with no tools and no loop.

| # | Stage | Kind | Who does it |
|---|-------|------|-------------|
| 1 | `scan.py` → pick sessions, oldest first, until today's $ budget is spent | dull | Python |
| 2 | `session_turns.py` → number the turns `[T12 user]` / `[T13 assistant]` | dull | Python |
| 3 | **Redact** secrets (regex: `sk-…`, `ghp_…`, `AKIA…`, `Bearer …`, PEM blocks, `KEY=` lines in pasted `.env`s) | dull, **security-critical** | Python |
| 4 | Oversized session (> ~60k tokens) → split on turn boundaries into chunks | dull | Python |
| 5 | **Summarize**: facts + `[James]`/`[Agent]` attribution + verbatim quotes, as JSON with a `turns: [..]` citation on every bullet | **critical** | cheap reasoning model |
| 6 | **Verify** (see below). Pass → continue. Fail → retry once on the escalation model, then quarantine | dull, **critical gate** | Python |
| 7 | Render `sessions/<slug>.md` + `_agent_behavior.md` from the JSON; gzip raw | dull | Python |
| 8 | `{#track-record}` → append the Concrete bullets straight to `track-record.md`, with no model involved | dull | Python |
| 9 | **Place** the other sections: input is the summary's `[James]` bullets plus a *numbered one-line index* of the existing bullets in only the touched sections (~3k tokens, not 250 KB). Output is an ops list: `{section, op: add\|reinforce\|tension, bullet_no?, text, anchor}` | semi-dull | cheapest model |
| 10 | Apply the ops to markdown (insert the bullet, append a footnote, add a `(tension: …)` note), update `stats.md`, `scan.py --mark` | dull | Python |
| 11 | **One commit per session** (today it's three) and one line in `runs.log` with the tokens and $ from OpenRouter's `usage` | dull | Python |

### Stage 6: the verification that makes a cheap summarizer safe

On 2026-09-04, haiku failed by **inverting attribution**. Numbered turns make that
mechanically checkable, so model quality doesn't have to be trusted:

- Every `[James]` bullet must cite ≥1 turn, and at least one cited turn must be a `user`
  turn. A `[James]` bullet backed only by assistant turns fails.
- Every quoted string in a bullet must appear **verbatim** in a cited turn. Invented quotes
  fail.
- Every cited turn number must exist, and every `anchor` must be one of the 10 taxonomy
  anchors plus `track-record`.
- JSON must validate against the schema. Request it with `response_format` /
  `structured_outputs`, which all the candidate models support.

Retry fails once on the escalation model. If it fails again, **quarantine**: write
`quarantine/<slug>.json` with the failure, don't mark the session processed, and move on.
A human looks later, or the next `pe` in Claude clears it. Quarantine must never be a
silent skip, so each run's report lists what's in it.

### Model picks (OpenRouter prices pulled 2026-09-24, $/M tokens in/out)

These models all postdate what I know first-hand, so **the prices are real but the quality
isn't proven yet**. Step 1 of the build is a bake-off.

| Role | First pick | Alternates | Why |
|---|---|---|---|
| Summarize (critical) | `deepseek/deepseek-v4.1-flash` $0.15/$0.60 | `openai/gpt-5.6-luna` $0.20/$1.20, `qwen/qwen3.8-flash` $0.15/$0.47 | Cheap with reasoning, 1M context, structured outputs |
| Escalation (retry) | `deepseek/deepseek-v4-pro-0813` $0.46/$1.39 | `google/gemini-3.8-flash` $0.75/$3.75 | Used only on verify failures |
| Place ops (dull) | `z-ai/glm-5.3-flash` $0.05/$0.60 | `deepseek/deepseek-v4-flash-0731` $0.03/$0.32 | Small input, short JSON output |
| `pe analyze` (rare) | stays manual; `openai/gpt-5.6-sol` $2/$10 or Claude | — | Open-ended reasoning over the whole profile, run on demand only, not from cron |
| *Reference* | `anthropic/claude-sonnet-5` $2/$10 | — | Baseline for comparison |

Model ids live in one config block (`pe_runner.toml` or env vars), not in code, so swapping
models needs no edit. `:batch` variants cost about half. Use them for cron once it's
confirmed that OpenRouter's batch semantics suit a nightly job.

### Estimated cost per mean session (≈21k tokens)

- Summarize: 23k in × $0.15 + ~5k out incl. reasoning × $0.60 ≈ **$0.0065**
- Place: ~6k in × $0.05 + 1k out × $0.60 ≈ **$0.001**
- Escalation on maybe 10% of sessions ≈ **+$0.002**
- **≈ $0.01/session**, versus ≈ $1 today. The 143-session backlog ≈ **$1.50**. Daily, at
  5–10 new sessions/day, ≈ **$0.05–0.10/day**. **Zero Anthropic tokens** on the cron path.

## Privacy: this is the private profile repo

- Set OpenRouter provider routing to `data_collection: "deny"` and require zero-data-retention
  providers, in the request body on every call, not only in account settings. Verify the exact
  field names against OpenRouter's docs when building.
- Stage 3 redaction runs **before** anything leaves the machine, and has its own self-check
  (known fake secrets in, `[REDACTED]` out).
- API key comes from the `OPENROUTER_API_KEY` env var or the macOS Keychain. It never goes in
  either repo. Set a hard spend limit on the OpenRouter key itself as a second budget
  backstop.

## Running it daily

- **macOS `launchd`** (`~/Library/LaunchAgents/com.shming.pe-runner.plist`) rather than cron,
  so a run missed while the laptop sleeps catches up. Daily at 03:00.
- **Guards:** a lock file (no overlapping runs), `--budget-usd 0.50` per run and
  `--max-sessions 25`, stop on the first HTTP 402/429, and skip any session modified in the
  last 2 hours (it's probably still open). This replaces today's "cap at 10" rule, which
  exists to protect Claude tokens, with a cap on dollars.
- **Output:** commits in `personal-profile` only (no push, unless wanted), a
  `runs.log` line, and optionally a macOS notification with processed / quarantined / $
  spent.
- `/shmorch pe` in Claude stays as the manual, interactive path. `workflows/personal-eval.md`
  gains a line pointing to the runner as the default for backlog burn-down.

## Build order

1. **Bake-off first, no plumbing.** A throwaway script sends the stage-5 prompt for 3 sessions
   to the 3 summarize candidates. Gold standard: session `d07dcb07`'s Sonnet re-run from
   2026-09-04, whose attribution was checked by hand, plus 2 more sessions run once through
   today's Claude pipeline. Compare attribution tags bullet by bullet and check that the stage-6
   verifier catches the bad ones. Cost ≈ cents. Pick the model here.
2. `pe_runner.py` stages 1–8 and 10–11, `--dry-run` (no writes) and `--limit N`, plus an
   assert-based self-check for redaction, turn numbering, the verifier and ops application.
3. Stage 9, placement ops. Run 5 sessions and diff the section-file changes against what the
   Claude pipeline would have done.
4. Burn down the backlog in 25-session runs by hand, reading the commits.
5. launchd plist, then the daily cron.

VERSION: MINOR (new tool + a changed workflow path). The role docs (`pe-summarizer.md`,
`pe-synthesizer.md`) stay the spec. Their rules become the runner's prompts plus stage-6
checks, so the rules don't fork.

## Open questions

- Does `session_turns.py` already drop tool-result noise? If not, trimming it in stage 2 is
  the cheapest cost cut available.
- Should chunked sessions (stage 4) be merged by code (concatenate sections, dedupe
  identical bullets) or by one extra cheap call? Start with code.
- Should the runner push `personal-profile` to its remote, or stay local-commit only?
