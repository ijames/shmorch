---
status: open
category: Features
---

↑ [Plan](index.md)
**In this section:** [backfill-migrate-claude-project-memory](backfill-migrate-claude-project-memory.md) · [beads-integration-investigation](beads-integration-investigation.md) · [build-md-richer-definition-of-done](build-md-richer-definition-of-done.md) · [core-role-workflow-command-boundary-cleanup](core-role-workflow-command-boundary-cleanup.md) · [cross-functional-ux-participant-awareness](cross-functional-ux-participant-awareness.md) · [cross-project-knowledge-base](cross-project-knowledge-base.md) · [curated-hand-held-init-of-shmorch-skill-repo](curated-hand-held-init-of-shmorch-skill-repo.md) · [dead-link-scan-after-folder-moves](dead-link-scan-after-folder-moves.md) · [deliberate-esc-esc-snapshot-boundaries-in-workflows](deliberate-esc-esc-snapshot-boundaries-in-workflows.md) · [docs-state-plans-directory-for-planning-artifacts](docs-state-plans-directory-for-planning-artifacts.md) · [docs-taxonomy-backfill-mechanism](docs-taxonomy-backfill-mechanism.md) · [documentarian-prioritizer-consume-outputs-don-t-accumulate](documentarian-prioritizer-consume-outputs-don-t-accumulate.md) · [file-folder-doc-expansion](file-folder-doc-expansion.md) · [generic-external-integration-provider-abstraction](generic-external-integration-provider-abstraction.md) · [graph-first-documentation](graph-first-documentation.md) · [init-self-guard](init-self-guard.md) · [init-should-explain-what-it-creates](init-should-explain-what-it-creates.md) · [messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace](messaging-provider-optional-per-project-not-hardcoded-to-one-zulip-workspace.md) · [meta-manager-role](meta-manager-role.md) · [orient-md-step-3-bound-plan-md-reads](orient-md-step-3-bound-plan-md-reads.md) · [Prompt goal-alignment / scope monitor](prompt-goal-alignment-scope-monitor.md) · [resume-md-bounded-tail-reads](resume-md-bounded-tail-reads.md) · [scheduler-integration](scheduler-integration.md) · [self-improve-output-location-enforcement](self-improve-output-location-enforcement.md) · [shared-state-branch-git-decoupled-state-layer](shared-state-branch-git-decoupled-state-layer.md) · [shmorch-core-md-breakup](shmorch-core-md-breakup.md) · [shmorch-repo-deploy-folder-research](shmorch-repo-deploy-folder-research.md) · [shmorch-stage-and-shmorch-release-commands](shmorch-stage-and-shmorch-release-commands.md) · [shmorch-verify-parity-check-command](shmorch-verify-parity-check-command.md) · [state-file-discipline-tracks-own-their-state-dev-owns-root-state](state-file-discipline-tracks-own-their-state-dev-owns-root-state.md) · [state-store-shape](state-store-shape.md) · [structural-focus-enforcement-no-nagging-mechanical](structural-focus-enforcement-no-nagging-mechanical.md) · [subagent-usage-guide-for-solo-dev](subagent-usage-guide-for-solo-dev.md) · [umbrella-meta-project-portfolio-and-project-aggregator](umbrella-meta-project-portfolio-and-project-aggregator.md) · [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md) · [version-monitoring-across-projects](version-monitoring-across-projects.md) · [Watch self-improve output and backfill execution](watch-self-improve-and-backfill-execution.md) · [workflow-subagent-delegation](workflow-subagent-delegation.md) · [wrap-md-blocker-tier](wrap-md-blocker-tier.md)

**pe pipeline: split generalization from concrete track record** — `pe-summarizer`'s
"Concrete" section (named projects, specific decisions, what actually shipped) only
lives in per-session files. `pe-synthesizer` folds everything into the 9 trait-taxonomy
profile sections (behavior, values, work style — all generalized-person content), and
`pe-analyzer` is explicitly told not to read session files in bulk. Result: by the
analysis layer, proper nouns and concrete deliverables are gone — heavy on verbs and
adjectives (meta-language about how James works), thin on what was actually built.
Raised 2026-08-18.

- Add a track-record home that survives synthesis: a 10th profile file (e.g.
  `profile/10-track-record.md`) that `pe-synthesizer` populates alongside the 9 trait
  sections — named projects, concrete feats, dates, outcomes, with the same citation
  discipline as the trait sections.
- Split `pe-analyzer`'s output into two tracks: the existing interpretive "what this
  means about the person" read, and a concrete "what was actually built" ledger.
- Touches: `agents/roles/pe-summarizer.md`, `agents/roles/pe-synthesizer.md`,
  `agents/roles/pe-analyzer.md`, `workflows/personal-eval.md`.
- Related: [universal-outcome-metrics-dimension](universal-outcome-metrics-dimension.md)
  — same underlying complaint (verb/adjective-heavy output, thin on measurable
  specifics), applied to project observability instead of the personal-eval pipeline.

**Status:** v1 shipped via PR #120 — `pe-summarizer`'s Concrete section always anchors
`{#track-record}`; `pe-synthesizer` gained `profile/10-track-record.md` as a 10th
section, populated with the same Reinforces/Adds/Conflicts discipline but kept literal
instead of trait-compressed; `pe-analyzer` gained a non-interpretive Track Record output
section. Bootstrapped in the (separate, non-public) `$PERSONAL_PROFILE_HOME` repo.

**Open follow-ups, deliberately not built yet — the file is empty, build these once it
shows real strain, not preemptively (researched 2026-08-18):**

- **Unbounded growth, same wall `session.md` already hit.** The 9 trait sections
  converge (new evidence mostly reinforces existing bullets); track-record entries never
  converge — every session with a deliverable adds a new one. At real scale this needs
  the same split `core/documentation.md` § session.md growth already prescribes:
  `profile/track-record/<project>.md` or `profile/track-record/YYYY.md` + an index,
  instead of one ever-growing file read in full every analyze pass.
- **Entity resolution isn't handled.** Same project gets named inconsistently across
  sessions (confirmed live: "DarkBadge" vs. "darkbadge" in `03-work-activities-process.md`
  bullets). For prose this doesn't matter; for a ledger meant to be grouped by project,
  it silently fragments one project's history across multiple headings. Needs a canonical
  project-name registry `pe-synthesizer` checks before creating a new grouping — the
  single biggest risk to the ledger staying scannable rather than just less lossy.
  Confirmed a second, sharper case 2026-08-22: `appadd`/`AppAdd` was renamed to
  `darkbadge`/`DarkBadge` (same product — the transcript `cwd` folder name changed, not
  just casing), and `profile/10-track-record.md` already carries both labels for what is
  one continuous project history. A true rename needs the registry entry to carry an
  aliases list (`darkbadge` ← `appadd`), not just a canonical-casing fix — and ideally
  supports retroactive re-grouping of already-written entries under the current name, not
  just going forward. Same "not built yet, no real strain at this scale" status as the
  rest of this list.
- **Status transitions aren't a case the Reinforces/Adds/Conflicts model covers.** That
  taxonomy is built for trait evidence. A concrete deliverable evolving idea → building →
  shipped → issue-found is none of the three cleanly: not a Conflict (nothing
  contradicts), not a clean Add (duplicates the project), and "Reinforces" doesn't fit
  since the fact itself changed, not just its evidence. Needs an explicit fourth verb —
  "Updates" — keyed on project+feature: append a dated status-change line to the existing
  entry rather than footnoting or duplicating.
- **`pe-analyzer`'s "read it whole" instruction won't survive the split in point 1.**
  Once track-record needs per-project/per-year files, the analyzer needs the same
  index-then-drill escape hatch it already has for `sessions/*.md` ("do not read all of
  these by default... drill into a specific one to verify a claim") — read the ledger's
  index/tallies, open a specific project file only when writing that project's ledger
  line.
- **No cross-linking between the two tracks yet.** A trait bullet citing a project and
  a track-record entry for the same project don't reference each other. Low cost when
  added: when `pe-synthesizer` touches both a trait section and track-record in the same
  pass, add a one-line cross-reference between them.
- Confirmed *not* a problem: the 9 trait sections already carry rich in-line specifics
  (project names, concrete incidents) in their example bullets — track-record is additive
  to that, not a replacement, and those bullets shouldn't be pruned toward pure
  abstraction just because track-record now exists.
- **`pe-synthesizer` isn't following its own "literal, not trait-compressed" instruction
  for track-record.** Confirmed 2026-08-22: `profile/10-track-record.md` is 48KB / 15
  bullets, but each "bullet" is a single run-on prose paragraph (one AppAdd entry is
  ~800 words as one sentence-chain) instead of a scannable ledger row (project | what
  shipped | date | outcome). This is the "unbounded growth" item above showing up as
  *unreadable per-entry* growth, live now rather than hypothetical. Needs a format cap
  in `pe-synthesizer.md`'s track-record instructions, not just the eventual per-project
  file split.
- **Spiked a dual abstract/tangible summary format 2026-08-22**, on branch
  `test/dual-summary-format` in `$PERSONAL_PROFILE_HOME` (not merged): `pe-summarizer`
  produces two independently-compressed bullet lists per session instead of prose
  paragraphs — Tangible (facts/decisions/names) and Abstract (trait reads) — each cited
  to line numbers in the raw turns file rather than session-level anchors. Tested against
  one small session only (`748c88a3`) as a comparison baseline against the production
  summary. Not decided whether this replaces `pe-summarizer`'s output format or the
  question is still open; needs testing against a large/messy multi-day session before
  any pipeline change.

---

**Future project, deliberately not started (raised 2026-08-22):** a "comprehensive
professional engine" that goes beyond this pipeline's current scope — pulling in sources
beyond Claude Code transcripts (blog.shming.com, LinkedIn, email) to cover the parts of a
person a coding-session corpus structurally can't (see analysis 2026-08-21 §4 Interests:
"nothing in 76 sessions evidences an interest outside software... the input is a Claude
Code transcript corpus"). Also flags a real open question about the pipeline's own
synthesis depth: `pe-analyzer` reading trait sections that are themselves a compression of
per-session summaries is two-layer synthesis-of-synthesis — whether that's acceptable
depends on whether the eventual use (job-fit, gap-spotting) needs human-readable prose at
every layer or only at the final output, and if it does need fixing, whether the fix is
flattening a layer out, more reasoning budget/model tier on the interpretive pass, more
harness (structured intermediate formats, verification passes), or just more/varied
source material diluting the coding-only skew. Not scoped further than this — a separate
project's problem once the pipeline in this doc has real strain, not a redesign to chase
now. See `README.md`'s own "Vision" section, which already names the aggregator/knowledge-graph
version of this as a deliberately separate future project.
