↑ [Prioritizer Runs](index.md)

# Priority proposal — 2026-08-28

Full backlog. Reconciled against `docs/project/tracks/*/index.md` status and `git branch -a`
before scoring (see Reconciliation below) — several plan/ items had drifted from track reality.

### Proposed Backlog Order

| Rank | Track | Value | Effort | Blocking | Risk | Rationale |
|---|---|---|---|---|---|---|
| 1 | resume-md-bounded-tail-reads | High | S | No | High | Already hit the 25K token truncation cap in production (DarkBadge, 2026-07-21). Same fix class as orient/wrap already shipped — just extend it. |
| 2 | orient-md-step-3-bound-plan-md-reads | High | S | No | High | Measured ~3,868 tokens, unbounded, growing every session. Same failure mode as #1, not yet hit the wall but will. |
| 3 | workflow-subagent-delegation | High | L | Yes | High | Active umbrella track (Approach A already measured at 69% context free). Several smaller Fixes-category items below are downstream of this track's scope — do this first, not around it. |
| 4 | shared-state-branch-git-decoupled-state-layer | High | L | No | Med | Real recurring pain (state files conflict on every branch merge). Track status is "Investigation" — decide this before touching #13, which it would supersede. |
| 5 | backfill-migrate-claude-project-memory | Med | M | No | Med | Active leak: project memory accumulating outside repo docs across every Shmorch-managed project, discovered via a real cross-contamination bug (DarkBadge content in shming.com's memory). Grows every session it's deferred. |
| 6 | version-monitoring-across-projects | Med | S | No | Med | Silent-failure risk: VERSION drift goes undetected until something breaks downstream. Cheap fix. |
| 7 | self-improve-output-location-enforcement | Med | S | No | Med | One line added to an existing Task prompt. |
| 8 | docs-taxonomy-backfill-mechanism | Med | S | No | Low | Re-scoped down: its linked track shows the mechanism is already built and piloted — remaining work is just running it against appadd/mobos/darkbadge, not designing anything. Plan text is stale (see Reconciliation). |
| 9 | documentarian-prioritizer-consume-outputs-don-t-accumulate | Med | M | No | Med | Meta: this very workflow just wrote a dated file to `docs/project/prioritizer/`. Worth fixing on its own merits, not because this run is hypocritical about it. |
| 10 | wrap-md-blocker-tier | Med | S | No | Low | Small, self-contained. |
| 11 | init-self-guard | Med | S | No | Low | Correctness bug (init should refuse to template-copy onto itself); cheap. |
| 12 | watch-self-improve-and-backfill-execution | Low | S | No | Med | Not a build item — a standing process reminder (don't let self-improve PRs stack up). Cheap to action (checklist add), real recurring cost if ignored (VERSION collision on batch merges). |
| 13 | state-file-discipline-tracks-own-their-state-dev-owns-root-state | Med | M | No | Med | Don't build alongside #4 — same problem, competing solutions. Only pursue if #4 is rejected. |
| 14 | core-role-workflow-command-boundary-cleanup | Med | M | No | Low | Its stated dependency (core-breakup) is now resolved — core-breakup absorbed into #3 and its own scope is done. Blocker is gone; ranked on merits now. |
| 15 | file-folder-doc-expansion | Med | M | No | Low | Design in progress per track, not blocked on anything. |
| 16 | graph-first-documentation | Med | L | No | Low | Architecture track, open, no urgency signal. |
| 17 | cross-project-knowledge-base | Med | M | No | Low | |
| 18 | shmorch-verify-parity-check-command | Med | L | No | Low | Prototype already exists in another repo to generalize from — not starting from zero. |
| 19 | messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace | Low | M | No | Low | `generic-external-integration-provider-abstraction` is the broader version of this — deferred below until this ships. |
| 20 | build-md-richer-definition-of-done | Low | S | No | Low | |
| 21 | init-should-explain-what-it-creates | Low | S | No | Low | |
| 22 | scheduler-integration | Med | XL | No | Low | Blocked (track status), not just unprioritized — needs the remote-agent-vs-CronCreate decision before any effort estimate means anything. Resolve the decision, don't schedule the work yet. |
| 23 | state-store-shape | Low | XL | No | Low | Exploratory; `beads-integration-investigation` below is the concrete trial version of the same question. |
| 24 | shmorch-stage-and-shmorch-release-commands | Low | M | No | Low | |
| 25 | subagent-usage-guide-for-solo-dev | Low | S | No | Low | Docs-only. |
| 26 | structural-focus-enforcement-no-nagging-mechanical | Low | S | No | Low | |
| 27 | cross-functional-ux-participant-awareness | Low | M | No | Low | Solo-dev project — "participants" scope is speculative until there's a second person in the loop. |
| 28 | docs-state-plans-directory-for-planning-artifacts | Low | S | No | Low | |
| 29 | prompt-goal-alignment-scope-monitor | Low | M | No | Low | Explicitly speculative in its own text; open design questions unresolved. |
| 30 | meta-manager-role | Low | M | No | Low | |
| 31 | curated-hand-held-init-of-shmorch-skill-repo | Low | M | No | Low | |
| 32 | deliberate-esc-esc-snapshot-boundaries-in-workflows | Low | M | No | Low | |
| 33 | umbrella-meta-project-portfolio-and-project-aggregator | Low | XL | No | Low | Biggest, vaguest item in the backlog. |

### Drops

- **dead-link-scan-after-folder-moves** — `status: done`, work shipped 2026-08-20. Graduate/archive, don't rank.
- **shmorch-core-md-breakup** — plan/ still says `status: open`, but its own text and its linked track (`tracks/20260601-core-breakup`, status **Absorbed**) say it was folded into `workflow-subagent-delegation` (Approach C) on 2026-08-10 and the original scope is done. Drop as a duplicate of #3 above.

### Defers

- **beads-integration-investigation** — condition: a project feels real pain from flat markdown task files, or Beads gets more usage examples. Unchanged.
- **generic-external-integration-provider-abstraction** — condition: a second non-messaging integration need actually appears. Unchanged.
- **universal-outcome-metrics-dimension** — condition: revisit once the pe-pipeline split (below) proves out in practice.
- **pe-pipeline-split-generalization-vs-concrete-track-record** — v1 already shipped (PR #120). Remaining scope is explicitly "build once it shows real strain, not preemptively" per the item's own text. Nothing to rank until that strain shows up.
- **shmorch-repo-deploy-folder-research** — item's own text: "do not build without a separate go-ahead." Condition: developer says go.

### Reconciliation

Cross-checked `docs/project/plan/`, `docs/project/tracks/*/index.md`, and `git branch -a`.
Findings:

1. **shmorch-core-md-breakup drift** — plan/ frontmatter still `open`; its track is `Absorbed`. See Drops.
2. **`tracks/20260724-dev-docs-taxonomy-backfill` is internally inconsistent** — frontmatter says `status: Closed`, the body's own `**Status:**` line says `Active`, and the summary says the mechanism is "built, piloted... wired into auto-update.md." Meanwhile `plan/docs-taxonomy-backfill-mechanism.md` still describes it as "Not designed yet — deliberately deferred." All three disagree. Resolved the plan ranking above around the track summary (mechanism exists); the track file itself needs a documentarian pass to pick one status.
3. **`tracks/20260717-docs-solidification-framework` is done but still marked Open** — frontmatter and body both say `Open`, but the summary states both concerns already shipped in PR #55 and the standalone `solidify` command was dropped. No plan/ item references this track at all — it's an orphan that should be closed, not ranked. Flagging for a documentarian pass, not a backlog decision.
4. **`tracks/20260602-scheduler-integration` is Blocked** — plan/scheduler-integration.md doesn't surface this; ranked accordingly above (#22) with the blocker called out instead of a normal effort estimate.
5. **Untracked in-flight work**: local branch `research/ai-native-sdlc-playbook` has 4 commits not on `main` (a determinism-ladder track proposal + a doctrine-load-verification plan item + blog revisions) and no corresponding entry in `docs/project/plan/` or `docs/project/tracks/`. Someone needs to file this before it can be scored — it isn't in this ranking.
6. **22 stale remote branches** (`js/*`) are fully merged into `main` (0 commits ahead) but still exist on the remote — chore/docs/feat/fix branches going back to at least 2026-08-11. Not a prioritization item, but violates the "no more than 2–3 open branches" guidance in `core/git-discipline.md` purely as remote clutter. Recommend a cleanup pass: `git push js --delete <branch>` for each, after confirming with `git log main..js/<branch>` that it's really empty (spot-checked above; all 22 returned 0).

### Notes

- No `docs/project/sprint.md` exists — this is a full-backlog prioritization, not sprint-scoped.
- No `docs/{product,technology}/decisions/` directory exists in this repo yet, so no decision-doc constraints fed into scoring.
- Two open Architecture items (#4 and #13) are mutually exclusive solutions to the same problem (state-file merge conflicts) — don't schedule both, pick one after resolving #4's Investigation.
- `scheduler-integration` (#22) is the only item where the real next action is a decision, not code — resolving the remote-agent-vs-CronCreate question would unblock it and probably changes its effort estimate.
