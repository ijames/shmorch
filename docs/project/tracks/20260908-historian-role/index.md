---
status: Investigation
updated: 2026-09-08
summary: New `historian` role — narrative + screenshot/diagram capture of a project's journey over time, for DarkBadge/Treeclusion articles first.
---

↑ [Shmorch Plan](../../plan/index.md)
→ `agents/roles/historian-narrator.md`, `agents/roles/historian-capturer.md`, `agents/roles/historian-diagrammer.md` (all new), `workflows/historian.md` (new), `commands/historian.md` (new)

# Track: `historian` role — visual/narrative project journey capture

**Status:** Investigation
**Opened:** 2026-09-08
**Domain:** New role/workflow (pipeline, not a section rewrite)
**Priority projects:** DarkBadge, Treeclusion (need articles). Applies to any
project with a UI: Paths, Mobos, Shming, Time Vortex.

## Why

Promoted from `docs/inbox/historian-visual-project-journey-role.md`. Developer:
"I've been missing the evolution of all my tools and there's definitely a story
and material for everything I'm doing here for publication and sharing."
Commits/tags/tracks capture *what* changed and *why* as engineering bookkeeping;
nothing today captures *what it looked like* as it changed, which is the raw
material an article or case study actually needs. Manual curation doesn't
happen because it doesn't scale — this has to be automated to exist at all.

Side pursuit, explicitly kept separate: reviewing decisions/analyses made along
the way and calling out the research behind them. Same narrative goal, different
mechanism (reading existing `docs/.../decisions/` and analysis docs, not
screenshot automation) — do not conflate the two into one role.

## Shape (three roles — third is research-only for now)

Modeled on the `pe-summarizer`/`pe-synthesizer` split (`workflows/personal-eval.md`):
one role gathers raw evidence, a second turns it into the durable artifact —
except here the artifact is a narrative history entry with embedded media, not
a profile-section fold.

### `historian-capturer` (mechanical, no judgment — evidence gathering)
- Input: a project + a point in its history (current `HEAD`, or a past merge
  commit/tag for retroactive mode).
- Drives `claude-in-chrome` (navigate + screenshot) against the project's dev
  server or a deployed preview, at a small fixed set of routes/views the
  project defines (e.g. a `docs/history/capture-routes.md` or
  frontmatter-listed set of "key screens" per project — home, the feature
  currently under active work, any route touched by the closing track).
- Also captures any Mermaid/architecture diagrams already in the repo as of
  that point (text-based, no rendering needed — just reference them).
- Writes screenshots as plain files, tagged with commit SHA + date. Does not
  write prose.
- **Candidate tool to try: Scribe (scribehow.com), 2026-09-23.** Free tier
  covers unlimited guides on web apps. Worth a dry run against DarkBadge or
  Treeclusion's web UI before building `claude-in-chrome` capture from
  scratch — but scoped narrowly, not a drop-in replacement:
  - It's a live, human-driven click recorder (browser extension/desktop app)
    that auto-generates an annotated screenshot-per-step guide as someone
    walks through a flow. It has **no video capability at all** — can't
    record, import, or review video, so it can't reconstruct behavior from
    an existing recording, only capture a flow as it's driven live.
  - Mobile capture exists but is **Pro/Enterprise only** (not the free
    tier) and, for a mobile web/browser flow, is semi-manual — screenshot
    before each tap, uploaded and click-tagged by hand, not automatic like
    desktop. True native-app mobile capture needs the desktop app driving
    an XCode Simulator or Android Emulator.
  - Has a read-only MCP server (`mcp.scribe.com/mcp`, OAuth) that lets an
    agent search/read guides already captured in a Scribe account — useful
    for pulling a guide's content into `docs/history/`, but it can't
    trigger a new capture; capture only happens through Scribe's own
    extension/app with a human at the wheel.
  - Net: a plausible fit for evidence-gathering during **forward capture**
    of a web-UI walkthrough (arguably a better one-shot artifact than raw
    screenshots, since it already annotates + sequences them), but it does
    nothing for retroactive mode (no historical checkout/replay) and
    doesn't reduce `historian-capturer` to zero build — still need to
    decide whether the pipeline consumes a Scribe guide's exported
    screenshots+captions as its evidence format, or keeps `claude-in-chrome`
    as the primary mechanism and treats Scribe as a manual/optional
    alternative for flows a human is walking through anyway.

### `historian-narrator` (judgment — the actual story)
- Input: a closed track's `index.md` (Why / What changes / Work log), the
  commits/PR it produced, and the capturer's screenshots for that point.
- Writes one narrative entry: what this chunk of work was, why it mattered,
  what changed visually (referencing the screenshots), pointing to the
  decisions involved. Assembles evidence into readable form — does **not**
  fabricate motivation beyond what the track doc/commits/decisions actually
  say, and does not draft publication-ready article prose in the developer's
  voice (matches his stated preference elsewhere: capture the evidence, don't
  ghostwrite for him — he writes the actual article from this material).
- Strong tier (like `pe-analyzer`, not `pe-synthesizer`) — this is open-ended
  synthesis of a narrative arc, not fixed-format folding.

### `historian-diagrammer` (research only — not scoped, do not build yet)
Developer's addition: capture C4 diagrams as part of the same journey, but
**model-based** — a single source that code, infra, docs, and tests derive
from or stay checked against, not a diagram someone redraws by hand and lets
drift. This is a different (harder) problem than the screenshot/narrative
pieces above and should not be built until it has its own real design pass —
tracked here as a research item, not a fourth thing to ship alongside the
other two.

Open questions to research, not answer yet:
- **IcePanel — deprioritized, not ruled out.** Developer's read was it has the
  best tooling of what he's seen, though not canon C4; there is an IcePanel
  MCP integration already present in this environment
  (`mcp__claude_ai_IcePanel__*`, currently just auth) that could test API/CLI
  access. But 2026-09-08: developer flagged pricing doesn't work for a solo
  dev — don't spend research time validating IcePanel's model/API/merge story
  until that changes. Default the research toward canonical C4 tooling
  instead (Structurizr DSL, C4-PlantUML) — free/self-hostable, at least
  text-diffable. **Does not by itself solve the merge-conflict concern
  below** — see the correction there.
- **Model-based, not diagram-based:** the goal is one underlying model
  (components, relationships) that generates the diagrams, and ideally that
  the code/infra can be checked against — not diagrams as independent
  hand-maintained artifacts that happen to sit near the code. Needs a real
  answer on what that model *is* (a DSL file? inferred from code via static
  analysis, e.g. the `infigraph` MCP tools already available here for
  architecture/dependency graphs? IcePanel's own model if it's API-accessible?)
  before anything about capture cadence matters.
- **Branch/merge-conflict risk — developer flagged this explicitly, then
  corrected an overclaim of mine (2026-09-08):** I initially assumed a
  text-first DSL (Structurizr, C4-PlantUML) "solves" this because it's
  line-diffable, same as normal code/docs. Developer pushed back: an
  architecture model is a *single shared structure*, not a naturally
  partitioned one the way code splits across files/modules — nearly any
  change on any branch touches the same model file, so conflicts would be
  frequent (potentially every change, not the occasional collision normal
  docs/code see), and resolving one correctly requires being fluent in the
  DSL's semantics, not just picking a side of a text diff the way a normal
  merge conflict works. Text-diffable is necessary but not sufficient — it
  does not make this a solved problem.
  Real options, unranked, all need vetting before picking one:
  - Don't hand-maintain a shared model file at all — derive the model
    per-branch from code (static analysis, possibly via the `infigraph` MCP
    tools already available here) so there's nothing to merge; each branch's
    "diagram" is just a regeneration, and only the *rendered* output
    (image/`.md`) is checked in, like `docs/history/media/` screenshots.
  - Partition the model itself along the same boundaries the codebase
    already partitions on (per-service/per-container files a C4 tool can
    compose at render time) so a branch only ever touches the slice it's
    actually changing — needs a tool that actually supports multi-file
    composition, not assumed to exist yet.
  - Treat the model as `main`-only, updated in its own dedicated step (like
    `wrap.md`'s state-file consolidation-on-`dev` pattern from
    `docs/project/tracks/20260609-state-file-discipline`) rather than
    something feature branches carry and merge — branches don't touch it at
    all until landing.
  Do not pick a tool or format before one of these (or another option) is
  actually chosen — the merge story is prerequisite, not a detail to solve
  after tool selection.
- Whether this ties to `historian-capturer`'s per-point captures (a diagram
  snapshot alongside each history entry) or is a separate, always-current
  artifact that historian just links to rather than versions per-entry.

## Where things go

- **Narrative entries:** `docs/history/<date>-<track-slug>.md` per captured
  point, one per project (i.e., this lives in each *target* project's own
  `docs/history/`, not in shmorch itself — shmorch only carries the role/
  workflow mechanics, same split as `personal-eval`/`personal-profile`).
  `docs/history/index.md` is a chronological index — the timeline itself,
  which is the point.
- **Screenshots/diagrams:** `docs/history/media/<date>-<track-slug>/*.png`,
  referenced by the narrative entry from the same date. Flat files, no DB —
  same "boring, greppable, git-diffable" bias as the rest of Shmorch's docs.
- **Decisions/research side pursuit:** no new location — reads what's already
  in the project's `docs/.../decisions/` and analysis artifacts; the narrator
  cites them rather than duplicating them into `docs/history/`.

## Triggers — nothing automatic

Matches the `personal-eval` precedent: browser automation and narrative
synthesis are both cost/attention-sensitive, so this is manual/on-demand only,
never a hook or wrap-time trigger.

- **Forward capture:** `/shmorch historian` (or `/shmorch historian <project>`)
  run manually, ideally right after a priority track closes (DarkBadge/
  Treeclusion first) while the app and the track's context are both fresh.
  Captures current state, runs the narrator over the just-closed track.
- **Retroactive backfill:** `/shmorch historian backfill <project> [--since <tag/date>]`
  — walks past merge commits/tags oldest-first, checks each out in a scratch
  worktree, attempts to run the app, screenshots on success, skips (logs, does
  not fail the batch) on any commit where the old build/run environment no
  longer works. Best-effort by design, not guaranteed complete history.

## Not resolved — needs scoping before building

- How a project declares its "key screens" to capture (frontmatter list?
  a small `docs/history/capture-routes.md`?) — needs a real convention, not
  guessed per project.
- Whether retroactive mode is worth building at all given the environment-rot
  risk, or whether it's scoped down to "as far back as still runs" and left at
  that.
- Exact `historian-narrator` prompt/taxonomy — this doesn't have an existing
  MECE structure like `personal-profile`'s to reuse; needs its own design pass.
- Whether DarkBadge/Treeclusion get bootstrapped by hand once (pick 3-5
  historical merge points, do the first pass manually) before automating,
  the way `pe` was validated on one project before being generalized.

## Work log

### 2026-09-08
Promoted from inbox capture (`docs/inbox/historian-visual-project-journey-role.md`,
filed same day). Scoped at a high level: two-role pipeline (`historian-capturer`
+ `historian-narrator`), output locations, and manual-only triggers decided.
No code/roles built yet — this track stays `Investigation` until the open
questions above have real answers, most likely starting with a manual dry run
on DarkBadge.

Same day, developer added a third piece: model-based C4 diagram capture
(`historian-diagrammer`), explicitly flagged as harder and research-only for
now. IcePanel was the initial candidate tool but the developer flagged its
pricing doesn't work for a solo dev — research defaulted toward free/text-
first C4 tooling (Structurizr DSL, C4-PlantUML) instead. Developer then
corrected an overclaim I made that text-first tooling solves the branch/
merge-conflict risk — a shared architecture model conflicts far more often
and far harder to resolve than normal docs/code, since almost any change
touches the same file and resolving it needs DSL fluency, not just diff
literacy. Real options logged (derive-per-branch/don't hand-maintain,
per-service model partitioning, main-only/no-branch-carry) but none chosen —
this is the single biggest open question blocking this piece.

### 2026-09-23
Developer asked about Scribe (scribehow.com) as a possible `historian-capturer`
tool, prompted by the `source-capture-tool.md` inbox item (unrelated — that's
about fetching blocked web content, not UI capture). Researched and logged
under `historian-capturer` above: free tier exists, has a read-only MCP
server, no video capability at all (screenshot-sequence only), mobile capture
is Pro/Enterprise-only and semi-manual. Candidate for forward-capture of a
live web-UI walkthrough; doesn't touch retroactive mode. Not yet trialed
against DarkBadge or Treeclusion.
