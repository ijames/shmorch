# Inbox

Drop files here — captured observations, friction points, proposals — and `self-improve`
will pick them up to evaluate and either apply, defer, or discard.

↑ [docs/](../README.md)

---

Items here are not authoritative. They graduate into `workflows/`, `core/`, `agents/`,
`tools/`, or a track once reviewed and accepted, or are removed once resolved.

**Open:** `infigraph-removal-commit-pending.md`, filed from `shming.com` 2026-08-31 —
Deferred 2026-09-03, premise went stale (see file for re-check instructions); point 4
(`.infigraph/` cleanup) still open, re-confirmed stale 2026-09-04.
`version-control-default-merge-strategy.md`, filed from `darkbadge` 2026-09-03 —
Deferred 2026-09-04, no default merge/rebase-before-merge doctrine for projects without
their own strategy; needs a real decision, not just drafting.
`observability-driven-development-watcher-gate.md`, filed from
`darkbadge` 2026-08-26 — Deferred 2026-09-04, candidate "no watcher, no error log"
PR-gate addition to `core/observability.md`/`workflows/build.md`; already applied
project-locally in DarkBadge, not yet validated as more than a one-project pattern.
`progressive-delivery-flag-dependency-chains.md`, filed from `darkbadge`
2026-08-04 — Deferred 2026-09-04, candidate "Dependency Chains" section for
`core/progressive_delivery.md`; DarkBadge's own case resolved via PostHog's native
support, no urgent driver.

(previously resolved: `pe-summarizer-attribution-cheap-tier-unreliable.md`, filed from
`shming.com` 2026-09-04 — sonnet-tier re-test of session `d07dcb07` got every
`[James]`/`[Agent]` bullet right (vs. haiku's ~5 inversions); `pe-summarizer` promoted
to default/strong tier in `workflows/personal-eval.md` and
`agents/roles/pe-summarizer.md`, 2026-09-04.
`pe-attribution-and-mece.md`, filed from `shming.com` 2026-09-04 —
applied 2026-09-04: `pe-synthesizer.md`'s stale generalized-trait wording replaced with
the `[James]`/`[Agent]` tag check, `pe-summarizer.md` gained attribution tagging plus a
parallel `<slug>_agent_behavior.md` output, MECE + `ambiguous-uncategorized.md` overflow
added to the synthesizer, numeric filename prefixes dropped across all 5 role/workflow/
command files.
`template-content-not-generic.md`, filed from `Paths` 2026-08-29 —
re-scoped as `docs/project/plan/template-content-genericity-detection.md` after a template
audit found the current template set clean, 2026-09-03.
`decisions-vs-directives.md`, filed from `shmorch` (self) 2026-09-01 — folded into
`core/documentation.md`'s "Decisions vs. directives" bullet, 2026-09-03.
`capture-aside-command.md`, filed from `darkbadge` 2026-08-27 — built
as `commands/aside.md` + `workflows/aside.md`, 2026-08-28.
`block-claude-project-memory-writes.md`, filed from `shming.com` 2026-08-26 — PreToolUse
hook added as `templates/.claude/hooks/pre-tool-memory-guard.sh`, wired into
`templates/.claude/settings.json`, 2026-08-28.
`backfill-migrate-claude-project-memory.md`, filed from `shming.com` 2026-08-26 — scoped to
`docs/project/plan/backfill-migrate-claude-project-memory.md` (not yet executed), 2026-08-28.
`no-staleness-nudge-for-blocked-tracks.md`, filed from `treeclusion` 2026-08-28 — CW-9 added
to `workflows/go.md`, 2026-08-28.
`prioritize-instrumentation-not-followed.md`, filed from `treeclusion` 2026-08-28 — Step 6
gate + stamp readback added to `workflows/prioritize.md`, 2026-08-28. `em-dash-rule-scope-and-liveness-gap.md`, filed from `shming.com`
2026-08-25 — scope-narrowing loophole closed in `core/engineering-standards.md:14`,
new rule-liveness paragraph added to `core/operations.md`, 2026-08-26.
`learning-log-external-reference-reconsider.md` and
`pre-commit-template-stale-taxonomy.md`, both filed from `treeclusion` 2026-08-18 —
learning-log dual-write adopted in `shmorch-core.md`/`workflows/learn.md`;
`templates/.githooks/pre-commit` updated to the current docs taxonomy, 2026-08-18.
`session-md-growth-split-rule.md`, also filed from `treeclusion` 2026-08-18 — growth
rule added to `core/documentation.md`, checks wired into `workflows/wrap.md`, 2026-08-18.
`markdown-no-hard-wrapping.md`, filed from `treeclusion` 2026-08-20 — doctrine added to
`core/documentation.md` § No Hard Wrapping + `core/engineering-standards.md`, 2026-08-20.
`dead-link-scan-after-folder-moves.md`, filed from `treeclusion` 2026-08-19 — scoped to
`docs/project/plan/dead-link-scan-after-folder-moves.md` (not yet built), 2026-08-20.
`wrap-step84-blocked-by-own-precommit-hook.md`, filed from `treeclusion` 2026-08-20 —
`templates/.githooks/pre-commit` allowlist widened to `.shmorch/`, `commit-session-state.sh`
now stages `.shmorch/AGENTS.md`, 2026-08-20)
