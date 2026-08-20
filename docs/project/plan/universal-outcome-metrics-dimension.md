---
status: open
category: Deferred
---

↑ [Plan](index.md)
**In this section:** [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

**Universal outcome/impact-metrics First-Class Dimension** — Observability
(`core/observability.md`) covers system health; Analytics (`core/analytics.md`) covers
user behavior. Neither captures concrete performance/outcome metrics — revenue, traffic,
TTFP, token/cost efficiency, AI responsiveness — so no shmorch project currently has a
place to record or be prompted for these. Raised 2026-08-18, alongside the same
diagnosis surfacing in the `pe` pipeline (see
[pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md)):
generalizable/narrative content crowds out concrete, quantified specifics unless
something explicitly makes room for the latter.

- Unlike the pe pipeline fix, this isn't a prompting fix — it requires each project to
  actually instrument and report numbers shmorch doesn't currently ask for. Bigger
  commitment: new `core/*.md` dimension doc, init-questionnaire trigger, template,
  stage-expectations ladder (same pattern as observability.md/analytics.md).
  - Condition: revisit once the pe pipeline split has shipped and the "concrete vs.
    generalization" distinction has proven out in practice there first.
