---
status: Open
category: process
updated: 2026-07-31
---





**In this section:** [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

# Watch self-improve output and backfill execution

**Why this exists:** the 2026-07-30 self-improve run produced 9 proposals that all became
independent PRs and sat unmerged for a full extra session before landing (this session,
2026-07-31) — merging required resolving a VERSION collision and several real content
conflicts at every step. Self-improve proposing faster than PRs get merged is a recurring
risk, not a one-off.

Separately, this batch shipped two backfill-relevant changes that need to actually reach
already-provisioned consuming projects, not just exist on `main`:
- `tools/backfill-plan-dir.sh` (PR #78, `plan.md` → `plan/` directory registry)
- The existing `tools/backfill-docs-taxonomy.sh` chain (PR #78 hooks the above into it)

**What to watch, going forward:**
1. **Don't let self-improve PRs stack up.** Merge each proposal's PR at the point it's
   opened (or within the same session) rather than batching many open PRs for a later
   merge sweep — the later the sweep, the more VERSION/content conflicts compound.
2. **When a consuming project runs `/shmorch sync` or `auto-update`,** confirm the
   `plan/` directory backfill and the docs-taxonomy backfill are actually offered and
   applied — don't assume the tooling landing on `main` means it reaches existing
   projects automatically.
3. Revisit `docs/project/plan/index.md`'s "Self-improve" note under Current Activities (already
   flags that self-improve proposes+PRs independently) — this item extends that with the
   concrete backfill-verification piece.
