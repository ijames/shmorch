---
status: Active
updated: 2026-08-10
summary: Merged `orient`/`reorient` into one command (`/shmorch orient [focus|readiness]`) with production readiness now default-on and a new AI/LLM area (ML Test Score + NIST AI RMF), `docs/project/interview-log.md` for dated answers with contradiction detection, OWASP LLM Top 10 as a build-time guardrail (design.md/critic.md, not interview questions), + `tools/merge-chain.sh`. Latest branch adds a Progressive Disclosure doctrine and a deferred knowledge-graph note.
---

## Since last entry — merged, undocumented — 2026-09-03 (via `/shmorch touch`)

PRs merged after 2026-08-28 that this log never caught up to: #126 pe pipeline tools/ move
(personal-profile's `scan.py`/`session_turns.py` relocated into `tools/`) + index-preview-cap
fix (regenerate, don't append, ~150 char cap — was accreting into 3-4KB comma-spliced lists),
#127 `core/tdd.md` Testing Depth Ladder (test rigor scaled to project `stage` + a form axis;
Gherkin/BDD vs. visual-regression distinction added), #130 `prioritize` reconciles `plan/`
against `tracks/`/git branches before ranking (full-backlog re-rank; filed
`tracks/20260824-determinism-ladder` — stranded on an unmerged research branch with no
plan/track entry until this run caught it), #131 `core/js_tooling.md` split into a new
`technologies/` tier (per-technology JIT context alongside Command/Workflow/Role/Core;
`technologies/javascript.md` + new `technologies/python.md`; VERSION 2.2.0 -> 2.3.0).

check-inbox 2026-08-28: 5 acted, 0 deferred — PreToolUse memory-guard hook
(`templates/.claude/hooks/pre-tool-memory-guard.sh`) blocks Write/Edit into `.claude` project
memory in Shmorch-managed repos; migration backlog item filed
(`docs/project/plan/backfill-migrate-claude-project-memory.md`); new `/shmorch aside` command +
workflow (`commands/aside.md`, `workflows/aside.md`) for mid-session capture; `go.md` CW-9
nudges on stale Blocked tracks; `prioritize.md` Step 6 gate + timelog stamp-readback added.
VERSION 2.1.6 -> 2.2.0.

Self-improve 2026-08-26: 0 proposals — 3 candidate patterns all already addressed (PR-cap
gate in self-improve.md Step 6, stop-hook escalation CW-8 in go.md, and the em-dash inbox
item, resolved concurrently). See `docs/project/self-improve/20260826-shmorch.md`.

check-inbox 2026-08-26: 1 acted, 0 deferred — em-dash rule scope-narrowing loophole closed
(`core/engineering-standards.md`) + rule-liveness paragraph added (`core/operations.md`).

Self-improve 2026-08-17: 2 proposals, 2 applied (PR #111 session.md drift check in go.md;
PR #112 MoBoS template contamination cleanup). Inbox cleanup: PR #113 cleared
go-resume-wrap-determinism (already tracked in the context-budget umbrella track). 3 open
PRs awaiting merge — at the self-improve cap, hold further proposals until these land.

## Since last entry — merged, undocumented — 2026-08-20 (via `/shmorch touch`)

PRs merged after 2026-08-19 that this log never caught up to: #121 self-improve output moves
into the skill repo (`~/.claude/` was wrong write target), #122 `session.md` split per
`core/documentation.md`'s growth rule (older entries moved to `docs/project/session/*.md`,
this file trimmed), #123 new `core/engineering-standards.md` doctrine, #124 track-index growth
trigger generalized + enforced at `wrap` (checked during `build` too as of the same-day
follow-up commit). Current branch (`docs/20260820-inbox-three-items`) has filed three inbox
items (dead-link scan after folder moves, markdown-no-hard-wrapping doctrine gap,
wrap-step84-blocked-by-own-precommit-hook) — not yet triaged.

## Since last entry — merged, undocumented — 2026-08-19 (via `/shmorch touch`)

PRs merged after 2026-08-17 that this log never caught up to: #114 self-improve session-log
stamp (PR #111/#112 outcome logged, no new content), #115 new `/shmorch check-inbox` command +
workflow (item-by-item inbox triage, wired into `go.md` at session start; VERSION 1.6.0), #116
new `/shmorch learn` command (user-directed knowledge capture to global `~/.shmorch/learning/`
or project `docs/reference/learning/`; self-audit mode when run with no args inside
`$SHMORCH_HOME`), #117 learning-log dual-write (local + global) and a stale pre-commit
exempt-path fix, #118 `shmorch-core.md` trimmed to a triage/dispatch tool (detail now owned by
the workflow files) + new `specification.website` MCP wired in, replacing `core/seo_geo.md`
with `core/web_spec_compliance.md` (VERSION 2.0.0 — template/scaffold structure change), #119
new session.md growth/split rule in `core/documentation.md` (split entries older than
`## Latest Session` into `docs/project/session/YYYYMMDD-<slug>.md` once this file grows past
threshold — **not yet applied to this file, which is now ~390 lines and a candidate**),
#120 pe-summarizer/synthesizer/analyzer gained a 10th "Track Record" profile section for
concrete, non-generalized track-record content (personal-profile-side changes committed
separately in the non-public `$PERSONAL_PROFILE_HOME` repo). Also: `check-inbox` ran twice on
2026-08-18 (2 acted + 1 acted, 0 deferred across both runs) — items already folded into the
PR #117/#118/#119 summaries above.

## Since last entry — merged, undocumented — 2026-08-14 (via `/shmorch touch`)

PRs merged after 2026-08-10 that this log never caught up to: #106 frontmatter-gated loading
(Approach A of the workflow context-budget umbrella — now `Done`, see
`docs/project/tracks/20260721-workflow-subagent-delegation/approach-a-frontmatter-gating.md`),
#107 personal-eval (pe) workflow + pipeline fixes, #108 VERSION bump to 1.4.0, #109 new
`/shmorch touch` command (light session/plan sync, VERSION 1.5.0). Approaches B and C of the
context-budget umbrella remain open.

## Same-session follow-up — 2026-08-10 — Progressive Disclosure doctrine + knowledge-graph note

**Branch:** `docs/20260810-progressive-disclosure-doctrine`

**What was done:** while building out `~/.shmorch/personal-profile` (a separate, non-public
repo) and adding a top-level "at a glance" summary + per-section preview to its
`profile/index.md`, generalized the pattern into a new `core/documentation.md` § Progressive
Disclosure: any AI-managed, human-consumable index needs a top-level summary and a
one-phrase-per-section preview before the full read, not just `docs/project/index.md`/
`docs/product/index.md`. Logged as an `additive` changelog row (no backfill). Also parked a
speculative note in `docs/project/pre-planning.md` on knowledge graphs as an aggregator over
multiple evidence sources (personal-profile, Treeclusion, Paths, shmorch's own `docs/`) —
structural/provenance links stay hand-authored, interpretive/interstitial relationships are
better generated on demand by a context-aware LLM than pre-authored exhaustively. Not scoped
as a project, just a lens parked for later.

**Files touched:** `core/documentation.md`, `docs/project/pre-planning.md`, `VERSION`
(`1.3.1` → `1.3.2`, PATCH — doctrine/doc addition, no behavior change).

## Latest Session — 2026-08-10 — reorient interview + deterministic merge-chain tool

**Branch:** `feature/20260810-reorient-and-merge-chain`

**What was done:**
- New `/shmorch reorient` command + `workflows/reorient.md`: a re-runnable, tree-gated
  interview (Project Focus & Shape; Production Readiness modeled on Google's SRE PRR).
  Each category and sub-question is opt-in/skippable — distinct from `orient.md`'s fixed
  one-time 6-question Context Setup, which now points to it. Wired into `SKILL.md`'s
  dispatch table and `commands/help.md`.
- Found and fixed a real bug while wiring the write target: `docs/technology/infrastructure`
  was added to `EXPECTED_DOCS` (in `self-improve.md` and `auto-update.md`) in PR #99 as a
  canonical scaffold dir, but no `templates/docs/technology/infrastructure/` ever existed —
  and it contradicts `docs/technology/architecture/index.md`'s explicit "infra is a topic
  inside architecture/, not a sibling dir" rule. Removed it from both `EXPECTED_DOCS` lists
  and `auto-update.md`'s directory check; reorient's readiness answers now write to the
  existing `docs/technology/architecture/observability.md` instead.
- New `tools/merge-chain.sh`: scripts `core/git-discipline.md`'s already-documented
  merge → pull → rebase → repeat PR-stack sequence, which kept getting skipped in practice.
  Merges each PR in order, pulls main, rebases the next branch, force-pushes on a clean
  rebase, and stops with exact resume instructions on a conflict (VERSION conflicts still
  need a judgment call, not auto-resolved). `git-discipline.md` now points to it.
- Two new tracks: `docs/project/tracks/20260810-adaptive-reorient-interview/`,
  `docs/project/tracks/20260810-deterministic-merge-chain-tool/`.
- `VERSION` bumped `1.0.7` → `1.1.0` (MINOR — new command/workflow).

**Files touched:** `commands/reorient.md` (new), `workflows/reorient.md` (new),
`workflows/orient.md`, `SKILL.md`, `commands/help.md`, `workflows/self-improve.md`,
`workflows/auto-update.md`, `tools/merge-chain.sh` (new), `core/git-discipline.md`, `VERSION`,
2 new track dirs.

**Same-session follow-up:** merged `reorient` back into `orient` before PR #102 ever
merged — `commands/reorient.md` and `workflows/reorient.md` removed, content folded into
`workflows/orient.md` as a "Deep interview" section gated on a `focus|readiness` argument;
new `commands/orient.md` makes it directly user-invocable (previously only reachable via
`go`). Added `docs/project/interview-log.md`: dated log of interview answers (Context Setup
+ deep interview), checked against prior answers and `docs/{product,technology}/decisions/`
for contradictions before each write — surfaced inline and logged, not silently overwritten.
This is the mechanism for keeping project scope changes intentional rather than accidental;
cross-linked (not merged) with `docs/project/plan/prompt-goal-alignment-scope-monitor.md`.
`VERSION` bumped `1.1.0` → `1.2.0` (MINOR — orient's command surface changed).

**Second same-session follow-up:** Production Readiness flipped from opt-in
("want to go through this? yes/skip") to default-on across all areas — assumed relevant
unless the user explicitly says skip/skip-all. Added a 6th area, AI/LLM development &
product integration, based on Google's ML Test Score (data/model/infra/monitoring rubric)
and NIST's AI RMF (governance question); depth is user's choice (quick pass vs full rubric)
and it captures an exposure level (public/internal/agentic). OWASP Top 10 for LLM
Applications deliberately kept out of the interview — instead applied as a standing
build-time guardrail scaled to exposure: `workflows/design.md` new Step 1c (design
constraints before build) and `agents/roles/critic.md` new check #6 (unaddressed category
for public/agentic exposure = BLOCKER, not RISK). `VERSION` bumped `1.2.0` → `1.2.1` (PATCH).

**Third same-session follow-up:** split `workflows/orient.md` (had grown to 335 lines mixing
shallow orientation, the deep interview tree, and the interview-log protocol) into
`workflows/orient.md` (shallow Steps 0-7 only, 197 lines) and a new `workflows/interview.md`
(deep Focus/Readiness/AI-LLM interview + recording protocol, 144 lines). `commands/orient.md`
dispatch updated accordingly. `VERSION` bumped `1.2.1` → `1.3.0` (MINOR — new workflow file).
PR #102 merged after this.

**Fourth same-session follow-up:** during the post-merge sync, a stray `chore(state)` timelog
commit ended up committed directly to local `main` mid-session instead of on the feature
branch — caused a real (non-force) divergence between local and remote `main` after PR #102
merged. Root-caused (not a `merge-chain.sh` bug — that commit predated the script's use and
was a plain manual-commit slip), then fixed properly: reset local `main` back to `js/main`,
moved the stray commit to its own branch, opened and merged PR #103, then hard-reset local
`main` to match (a true fast-forward, not a force-push, since nothing else was ahead). Branch
deleted after merge. Follow-up hardening: added a "Before pushing a branch or merging its PR"
rule to `core/git-discipline.md` requiring `docs/project/session.md` be current before the
final push/merge of a branch, referenced from `tools/merge-chain.sh`'s header. `VERSION`
bumped `1.3.0` → `1.3.1` (PATCH).



## History

<!-- Entries older than the current activity above, split out per core/documentation.md's
     session.md growth rule (added PR #119). Newest first. -->

- [2026-08-09](session/20260809-inbox-fixes-autoupdate-prioritize.md) — inbox fixes: auto-update scaffold gaps + prioritize reorder (PR #99)
- [2026-08-04 to 2026-08-05](session/20260804b-catchup-pr95-97-98.md) — catch-up: PRs #95, #97, #98
- [2026-08-04](session/20260804a-session-state-pr91-semver-role-composition.md) — PR #91 merge + semver migration + role-composition clarify
- [2026-08-01 to 2026-08-04](session/20260801-catchup-pr88-89-90.md) — catch-up: PRs #88, #89, #90
- [2026-07-31](session/20260731-merge-sequence-self-improve-batch.md) — merge sequence for self-improve batch (#67-#87)
- [2026-07-30](session/20260730-self-improve-batch.md) — self-improve batch (9 PRs, #75-#84)
- [2026-07-21](session/20260721-track-graph-audit-interrupted.md) — track-graph-audit tool (interrupted, PR #60)
- [2026-07-18](session/20260718-wrap-friction-bounded-reads-okf-frontmatter.md) — wrap-friction fixes, bounded session/timelog reads, OKF frontmatter comparison
- [2026-07-17](session/20260717-multicli-p2-entrypoint-p2-docs-solidification.md) — multi-CLI portability P2, entry-point consolidation Phase 2, docs solidification
- [2026-07-14](session/20260714-launcher-echo-fix.md) — shmorch.sh launcher echo fix
- [2026-07-07](session/20260707-multicli-portability-p0p1-entrypoint-p1.md) — multi-CLI portability P0+P1, entry-flow consolidation Phase 1
- [2026-06-11](session/20260611-self-dev-setup.md) — shmorch.sh self-dev setup
