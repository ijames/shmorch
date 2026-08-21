---
status: Open
category: process
updated: 2026-08-09
---



**In this section:** [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

# Prompt goal-alignment / scope monitor

**Why this exists:** raised at 2026-08-09 wrap. Without sprints or deadlines, scope
discipline on a solo project runs on impulse, sensitivity, and ad-hoc prioritization alone —
there's no external forcing function. A given prompt/request can be a "now" thing, a
"later" thing, or something that should get bundled into an existing track/feature instead
of starting a new thread — but nothing currently helps make that call before work starts.

**Idea:** some kind of lightweight check, run against an incoming prompt/directive, that
estimates distance from current goals/active track and suggests one of: proceed now,
defer to backlog, or fold into an existing track/feature. Not meant to gate or nag — more a
single reflective prompt at the point of intake, similar in spirit to `prioritize`'s
scoring but applied earlier, before a track even exists.

**Open questions:**
- Is this a `prioritize`-workflow extension (score on intake, not just backlog) or a
  separate lightweight check?
- Deterministic heuristic (keyword/track-file overlap) vs. an AI judgment call — cost/value
  tradeoff for something meant to run on every prompt, not just at session boundaries.
- Risk of becoming exactly the kind of mechanical nagging `structural-focus-enforcement-no-nagging-mechanical.md`
  already warns against — needs to stay a prompt, not a gate.
