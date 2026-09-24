---
priority: 34
status: open
category: Fixes
---

↑ [Plan](index.md)
**In this section:** [backfill-migrate-claude-project-memory](backfill-migrate-claude-project-memory.md) · [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [doctrine-load-verification](doctrine-load-verification.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [pe-pipeline-split-generalization-vs-concrete-track-record](pe-pipeline-split-generalization-vs-concrete-track-record.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [Source-capture tool: fetch web content into `sources/`](source-capture-tool.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [template-content-genericity-detection](template-content-genericity-detection.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

# Agent scope check and per-project window identity

Graduated from `docs/inbox/agent-window-confusion.md` (check-inbox 2026-09-23).

## Problem

Two cases so far where a Shmorch agent acted on, or wrote output into, the wrong project:

- **2026-09-18, wrong window (input):** a Circadence DevOps interview-prep request was
  typed into the JKAM/system agent because the terminal windows look almost identical. JKAM
  searched the Desktop, ran web searches and drafted prep. The work was already in
  `shming.com.private/opportunities/20260902-circadence-devops/`, so it was duplicated, done
  blind, and quoted a salary range from the wrong posting.
- **2026-09-21, wrong destination (output):** a session in the skill repo was asked a
  DarkBadge product question (extract the scoring system as a SaaS). It named DarkBadge in
  its own prose, then filed the analysis into the skill repo's `docs/inbox/`. It had to be
  moved by hand to DarkBadge's inbox.

The first case is about incoming requests; the second is about where output lands. Both
come from the same gap: the agent never asks whose concern this is before acting.

## Plan, in order

1. **Visible identity (prevents it).** A SessionStart hook, set up by `init` and repaired by
   `go`, sets the terminal title with an OSC escape to the project name from `context.md`.
   Where the CLI supports it, it also sets a per-project session colour (Claude Code's
   `/color`, which James was already setting by hand). Needs: how a hook can drive `/color`,
   or whether title alone is enough.
2. **Scope check (catches what slips through).** A short rule in `shmorch-core.md` Identity:
   - *Before acting* on a request clearly outside `context.md`'s "What This Project Does",
     stop and say so in one line, naming the likely home project. Proceed only if told to.
   - *Before writing* an artifact whose subject is another project, check the destination:
     write to that project's `docs/inbox/`, not the current one. Leave it uncommitted there,
     because committing is that project's session's job.
3. **Project registry (follow-up, not in this item).** A registry of known projects, such as
   `~/Projects/*/.shmorch`, so the agent can say where something belongs without guessing.
   Build it only if steps 1 and 2 don't reduce these incidents enough. It overlaps with
   [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md).

## Done when

- A new session in any initialized project shows that project's name in the terminal title.
- The Identity section has the two-part scope check, and it's covered by a scenario in the
  eval or critic checklist.
