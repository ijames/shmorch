# Inbox

Drop files here — captured observations, friction points, proposals — and `self-improve`
will pick them up to evaluate and either apply, defer, or discard.

↑ [docs/](../README.md)

---

Items here are not authoritative. They graduate into `workflows/`, `core/`, `agents/`,
`tools/`, or a track once reviewed and accepted, or are removed once resolved.

**Open:**
`plan-item-graduation-undefined.md`, filed from `darkbadge` 2026-09-17 — Deferred
2026-09-23, kept at this path because `workflows/touch.md` links here as the gate on
plan-pruning. There is no graduation path yet for plan items, and how plan, track, feature
and project relate is undefined.
`close-tracks-on-merge.md`, filed from `darkbadge` 2026-09-16 — Deferred 2026-09-23. `touch`
now reconciles `tracks/index.md` on every `resume`/`wrap` (PR #149). Revisit merge-time
enforcement if the table drifts again anyway.
`engagement-docs-have-no-home.md`, filed from `JKAM/system` 2026-09-18 — Deferred
2026-09-23 until a second client project needs a `docs/project/engagement/` folder.
`hooks-self-install-gap-and-readme-drift.md`, filed from `shmorch`
(self) 2026-09-08 — `shmorch-ln` never self-installed `.githooks/`/`.claude/hooks/`
(client-only via `init`); README's Safety section also overstates what
`pre-tool.sh` actually blocks (no direct-push-to-main check exists in it).
`pe-project-rename-mapping.md`, filed from `shming.com` 2026-09-04 —
fix already applied directly in `~/.shmorch/personal-profile` (separate repo, no PR
needed there: `project-aliases.yaml` + `read_meta()` alias resolution, commit
`466ecbf`); open item is just documenting the mechanism in
`workflows/personal-eval.md`/`agents/roles/pe-summarizer.md`.
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
(previously resolved: `agent-window-confusion.md`, filed from `JKAM/system`
2026-09-18 — graduated to `docs/project/plan/agent-scope-check-and-window-identity.md`,
2026-09-23. `source-capture-tool.md`, filed from `JKAM/system` 2026-09-18 — graduated to
`docs/project/plan/source-capture-tool.md` (planned for use across Shmorch plus DarkBadge's
Lambda), 2026-09-23. `node-complete-without-its-links.md`, filed from
`shming.com` 2026-09-22 — folded into `core/documentation.md` § Progressive Disclosure as
a sixth recursive bullet plus a link-stripped pass on the depth read test, 2026-09-23.
`infigraph-removal-commit-pending.md`, filed from `shming.com` 2026-08-31 — decided
2026-09-23: prefer static, diff-based analysis over a dynamic re-scanning tool; the
`.infigraph/` directory should be removed (sandbox blocked the deletion this session,
flagged for the developer to run by hand: `rm -rf .infigraph/`).
`track-info-retention-vs-graduation.md`, filed from
`darkbadge` 2026-09-16 — doctrine already covered tracks staying permanent; the
real gap (plan/sprint staleness enforcement, track-destination graduation checks)
fixed same day via the `close-tracks-on-merge.md`-adjacent `touch` upgrade.
`historian-visual-project-journey-role.md`, filed from
`shmorch` (self) 2026-09-08 — promoted same day to
`docs/project/tracks/20260908-historian-role/index.md` for scoping.
`pe-track-record-out-of-order-dates.md`, filed from
`shming.com` 2026-09-05 — `agents/roles/pe-synthesizer.md`'s `{#track-record}`
paragraph now compares the new session's own date against the existing entry's
cited date(s) instead of processing order before updating a status, 2026-09-05.
`pe-summarizer-attribution-cheap-tier-unreliable.md`, filed from
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
