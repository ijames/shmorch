---
status: done
category: process
---

↑ [Plan](index.md)
**In this section:** [backfill-migrate-claude-project-memory](backfill-migrate-claude-project-memory.md) · [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [doctrine-load-verification](doctrine-load-verification.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

**Dead-link scan after folder moves** — `tools/backfill-docs-taxonomy.sh` moves docs files via
`git mv` but never re-checks relative markdown links in the moved files (or their siblings) for
staleness; `tools/docs-audit.sh` already has DEAD_LINK detection, it just isn't wired into the
move step. Found via `treeclusion`'s 2026-08-19 backfill run: a moved file's own "In this
section" nav line (pre-dating the move) kept bare same-directory hrefs that no longer resolved
one directory deeper, and a sibling file moved into the same new directory carried an identical
stale copy. The same audit run also surfaced pre-existing dead links elsewhere unrelated to this
move — nothing currently re-runs the audit after either a mechanical backfill move or hand-edited
restructuring, so drift only surfaces when a human notices a broken link by chance.

Two smaller fixes bundled in, found by the same audit run:
- `docs-audit.sh`'s DEAD_LINK check strips backtick-code-spans before scanning but not
  multi-line HTML comment blocks, so intentionally-unresolvable example syntax inside
  `<!-- ... -->` (e.g. `sprints/index.md`, `tracks/index.md` template rows) gets flagged as a
  false positive.

**Done, 2026-08-20:** leveraged `docs-audit.sh`'s existing DEAD_LINK check rather than building
anything new.
1. `tools/docs-audit.sh` — now strips `<!-- ... -->` blocks alongside the existing backtick-span
   strip, before the DEAD_LINK grep.
2. `tools/backfill-docs-taxonomy.sh` — after the mechanical `git mv` loop, calls
   `docs-audit.sh` and prints any `DEAD_LINK` findings under a new report section, alongside
   the existing JUDGMENT list. No auto-fix (target directory for a stale link isn't always
   mechanically inferable). Verified against a synthetic repo reproducing the exact
   `treeclusion` scenario (a moved file's own same-directory link stranded by the move).

**Not done — left as a future judgment call:** extending the same DEAD_LINK-after-move check
to `workflows/vacuum.md` (or another hook) for manual `git mv`/rename of a docs file outside
the taxonomy backfill script specifically. Not scoped here; revisit if manual doc moves keep
producing the same class of drift.

Filed from `treeclusion` 2026-08-19; actual dead links in that repo were fixed directly there,
not part of this item.
