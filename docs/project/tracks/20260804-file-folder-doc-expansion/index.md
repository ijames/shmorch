---
status: Active
updated: 2026-08-04
summary: Design phase — deterministic file→folder doc expansion (threshold-triggered split, split by a two-phase deterministic+subagent architecture) plus time-based session folders; backfill-plan-dir.sh and track Work-log splitting retarget onto the same generic tool.
---

↑ [Shmorch Plan](../../plan/index.md)
→ `core/documentation.md` (new doc-expansion section) + `tools/` (new splitter script) + `workflows/wrap.md`/`session.md` handling

# Track: File→folder doc expansion

**Status:** Active
**Started:** 2026-08-04
**Domain:** Documentation architecture

## Why

`docs/project/session.md` (and other single files — `context.md`, `plan/index.md`,
individual `docs/{product,technology}` pages) grow without bound as a project matures.
Shmorch already splits *tracks* into per-track files and has size-threshold guidance for
tracks (`core/documentation.md`'s ~200-300 line rule, enforced by
`tools/track-graph-audit.sh`), but nothing does the equivalent for a single doc file that
has itself outgrown its single-file form. "For a project of any size... sessions can't
simply be a file but must be a folder" — the same outgrowing pattern applies generically,
not just to `session.md`.

Two related but distinct mechanisms are in scope, sharing infrastructure:

1. **Generic threshold-triggered file→folder splitter.** Any `docs/**/*.md` file that
   crosses a line/size threshold gets mechanically converted: `foo.md` →
   `foo/` containing an index file plus one file per original block (section), each
   stamped with front-matter and linked (`↑`/`→`/`↔`) to related docs, same discipline as
   `docs/project/tracks/*/index.md` already uses.
2. **Time-based session folders.** `docs/project/session.md` specifically converts to
   `docs/project/session/` — one file per session (or per day), plus a `current.md` that
   always names the in-flight session's topic(s). This is the same folder-ization idea
   but the split boundary is time/session-based rather than content-block-based, and it
   needs an always-current pointer file rather than a static index.

**Sort-order convention, resolved 2026-08-04:** any file meant to summarize/organize the
rest of a folder's contents (an index, a `current.md`) is prefixed with `~` (ASCII 0x7E),
which sorts after every digit and letter in plain byte-order listing (`ls`, `find`, `git
ls-files`, most language `sort()`s) — so it reads last, beneath the chronological content
it summarizes. Chosen over prefixing to force it first (`!index.md`) because these docs
are meant to be read as a chronological log with the organizing element at the bottom,
matching how `session.md`'s "Latest Session" entry already sits above older ones today —
inverted here since folder order is now sort order, not manual reverse-chronological
editing.

**Block-partitioning architecture, raised 2026-08-04:** figuring out where the split
boundaries fall inside a given large file is not uniformly mechanical — `session.md`'s
blocks are dated entries, `plan.md`'s are `### category` + `- [ ] **item**` list entries,
a track's Work log is dated/versioned rounds, and an arbitrary `docs/**/*.md` page might
only have `##` headings to go on. Splitting this into two phases: a **deterministic
outer loop** (threshold detection, file/dir creation, front-matter stamping, git mv) that
is genuinely file-shape-agnostic and belongs in the script — and a **model-driven inner
step** for the part that varies per file shape (deciding where the blocks actually
are), delegated to a subagent so the file-shape judgment doesn't have to be hardcoded
per doc type. A second follow-up subagent pass handles cross-linking the newly split
files (`↑`/`→`/`↔`) once boundaries are settled, since correct links depend on the final
file set. Net shape: script drives shell mechanics + orchestration, agent 1 proposes the
split points, script executes the split, agent 2 wires up links. Still open: how the
script hands the file to agent 1 (whole file in context vs. chunked), and what the
agent's output contract looks like (line ranges? heading list? confidence score per
boundary?).

## What changes

- `core/documentation.md` gains a new section: file→folder expansion — the threshold,
  the conversion procedure (block detection, per-file front-matter, linking), and the
  `~name.md` organizing-file convention (generalizes beyond just index files — applies to
  any "summarizes the folder" file, e.g. `~current.md`).
- New deterministic script (name TBD, likely `tools/split-doc.sh` or similar) that
  performs the conversion — mirrors `tools/track-graph-audit.sh`'s
  detect-then-report style; actual splitting likely needs a driven step (agent or
  scripted) since block boundaries and title extraction aren't purely mechanical for
  every doc shape.
- `docs/project/session.md` migrates to `docs/project/session/` with `~current.md` —
  `workflows/wrap.md` (writes new session entries) and `workflows/resume.md`/`go.md`
  (read session state) need their read/write logic updated to the new location.
- `templates/docs/project/session.md` (the scaffold shipped to new projects) either
  starts as a folder from `init` onward, or stays a flat file until it first crosses the
  threshold — open implementation question, see Work log.
- `tools/backfill-plan-dir.sh` retrofits onto the generic splitter once it exists, rather
  than staying a hand-rolled one-off — its Current Task / Backlog / Completed sections
  and per-item file output are exactly the kind of "block shape" the generic tool needs
  to support, and it's a good first real test case for the splitter's block-detection
  contract.
- Track `index.md` Work-log splitting (`core/documentation.md`'s 200-300 line rule,
  currently only *detected* by `tools/track-graph-audit.sh` with no automated split step)
  becomes a third consumer of the same generic splitter, using dated Work-log rounds as
  its block shape — closes the gap between "flagged" and "fixed" that the audit script
  currently leaves to a manual pass.

## Work log

### 2026-08-04

Track opened. Scope and sort-order convention confirmed with developer (see Why). Not
yet designed: the actual size/line threshold number, what counts as a "block" for the
generic splitter (any `##` heading? only top-level?), whether `templates/` ships
pre-folderized or converts on first threshold breach, and how `workflows/wrap.md`'s
existing single-file session-entry-append logic changes shape once `session.md` is a
folder of many files instead of one growing file. Next step: spec these open questions
before writing the splitter script or touching `wrap.md`.

Follow-up discussion (same day, raised from a DarkBadge project session hitting this gap
live via `/shmorch auto-update` — `session.md` had grown large with no split offered):
confirmed the generic splitter should be the thing `backfill-plan-dir.sh` and track
Work-log splitting both retarget onto, not stay separate one-offs (see What changes).
Also proposed a two-phase split architecture — deterministic outer script for threshold
detection/file creation/front-matter, model-driven subagent for the per-file-shape block
boundary judgment (since that part isn't uniformly mechanical across
session/plan/track/arbitrary-doc shapes), plus a second follow-up subagent pass for
cross-linking the split files once boundaries settle (see Why). Output contract for the
boundary-detection subagent (line ranges vs. heading list vs. confidence score) still
open. Next step unchanged: still need the threshold number and templates/ scaffold
decision before code starts.
