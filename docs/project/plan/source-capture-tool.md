---
priority: 35
status: open
category: Features
---

↑ [Plan](index.md)
**In this section:** [Agent scope check and per-project window identity](agent-scope-check-and-window-identity.md) · [backfill-migrate-claude-project-memory](backfill-migrate-claude-project-memory.md) · [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [doctrine-load-verification](doctrine-load-verification.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [template-content-genericity-detection](template-content-genericity-detection.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

# Source-capture tool: fetch web content into `sources/`

Graduated from `docs/inbox/source-capture-tool.md` (check-inbox 2026-09-23). Filed from
JKAM/system 2026-09-18.

## Why

All of Claude's fetch paths are blocked from Reddit. WebFetch and WebSearch return "not
accessible to our user agent", and Claude in Chrome returns "not allowed due to safety
restrictions". DarkBadge was never using them. Its Lambda worker calls Reddit directly with
stdlib `urllib` (`app/shared/scoring_pipeline.py::fetch_reddit`), and a similar stdlib
download → validate → store pattern exists in `app/shared/asset_capture.py`.

James (2026-09-19): "for research this isn't really automation, just augmented manual
fetching." A person asks, the tool fetches once and files the result. It isn't a crawler or
a scheduler.

## Goal (2026-09-23)

**Make it useful across Shmorch assets, and able to run in Lambda on DarkBadge.** It's one
fetch core with two front ends, not two tools.

## Shape

```
tools/capture.py                 # stdlib only (urllib, json, hashlib); no new dependency
  fetch(url | query, site=None) -> Capture(url, fetched_at, sha256, content_type, body, status)
  adapters: "web" (plain HTML/text), "reddit" (OAuth API)   # add others when a project needs one
  main(): CLI → writes sources/<site>/<date>-<slug>.{md,json} + a sidecar with url/time/hash
commands/capture.md → workflows/capture.md   # /shmorch capture <url|query>
```

- **Library use (Lambda):** `fetch()` returns data and writes no files, so a Lambda can
  import it and store the result wherever it likes (S3, Postgres). No filesystem assumptions,
  no global state, credentials read from the environment.
- **Agent/CLI use (Shmorch projects):** the command writes into the project's `sources/`,
  and research docs cite the saved capture instead of typing URLs from page titles.
- **Getting it into DarkBadge:** open question. Options are (a) vendor the single file into
  `app/shared/` with a version header comment, (b) publish a tiny pip package, (c) a git
  submodule. Leaning (a): one stdlib file, no packaging, and Lambda bundles it like any other
  module. Upgrade to (b) if a second deployed consumer shows up.

## Rules to settle before building

- **Official APIs where they exist.** For Reddit that's OAuth with the user's own app key,
  kept in the environment and never in the repo. ⚠ DarkBadge's current `fetch_reddit` uses
  the public no-auth `search.json` endpoint. Moving DarkBadge onto this tool means moving it
  to OAuth too, which needs an app key in that Lambda's secrets.
- **Identify honestly.** A real User-Agent naming the tool and its owner. Rate-limit, and
  cache so the same URL isn't fetched twice within a TTL.
- **Don't get around blocks.** No proxies, mirrors, or copied browser User-Agents. If a site
  refuses, record the refusal and move on.
- **Leave JavaScript-rendered pages to the browser.** This tool handles pages and APIs that
  return plain text or data only.
- **`sources/` in git:** by default, raw captures stay local (gitignored) and only summaries
  plus URL/hash are committed, since captures may contain copyrighted third-party text.

## Scope

- MINOR `VERSION` bump (new command).
- Build it from a session in `$SHMORCH_HOME`, not from a consumer project (cross-repo rule in
  `core/operations.md`).
- A shming.com researcher API built on this is a separate, later idea, already filed in
  shming.com's own inbox. Not part of this item.

## Done when

- `python3 tools/capture.py <url>` and `python3 tools/capture.py --site reddit "<query>"`
  write a capture plus its sidecar, and an `assert`-based self-check covers the slug, hash
  and cache paths.
- `/shmorch capture` works in at least one project (JKAM or shming.com).
- DarkBadge's `fetch_reddit` is replaced by an import of the vendored `fetch()`, or the
  decision not to do so is recorded here.
