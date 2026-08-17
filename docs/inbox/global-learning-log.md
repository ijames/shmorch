# Proposal: global (user-owned) learning log, not per-project

**Source:** session in project `treeclusion`, 2026-08-17
**Status:** Proposed, developer-approved for filing (not yet applied — developer chose to scope
and build this now rather than leave it deferred)

## Pattern

`shmorch-core.md` (§Identity, "Learning log") directs: *"When a concept surfaces that the
developer clearly didn't have context for, add it to `docs/reference/learning.md` without being
asked."* That log lives per-project. Most captured concepts aren't project-specific — they're
true on any project the developer touches next (this session's example: RST vs. RTF, what
Sphinx actually is, XSS risk living in the render step rather than the parse location — none of
that is treeclusion-specific). A per-project log means the same concept gets re-captured (or
missed) project to project, and there's no single place the developer can go to review what's
been learned across all work.

This exact gap was already noticed once, from inside the skill itself: `docs/project/pre-planning.md`
§"Global learning log, not per-project (deferred)" (added 2026-08-13, during a DarkBadge PR
merge) proposed the same fix and explicitly marked it **"Not scoped. Thinking-out-loud stage
only — revisit if per-project learning-log duplication actually becomes a recurring annoyance."**
It has now recurred in a second project (treeclusion, 2026-08-17), which is the trigger to scope
it.

## Evidence

- `shmorch-core.md:71` — the live capture directive, still points at project-local
  `docs/reference/learning.md`.
- `docs/project/pre-planning.md:223-244` — the prior "thinking out loud" note, unscoped,
  proposing `~/.shmorch/learning/` (or similar global, user-owned location) as the fix, with
  project docs keeping a link back rather than owning content directly.
- `~/.shmorch/` currently contains only `personal-profile/` — no `learning/` directory exists.
- treeclusion session 2026-08-17: captured a `docs/reference/learning.md` with two entries
  (Sphinx's layered architecture; XSS risk vs. parse location) that are general-purpose
  knowledge, not treeclusion-specific — concrete second instance of the duplication problem the
  pre-planning note anticipated.

## Proposed change

Files:
- `shmorch-core.md` — update the "Learning log" line under Identity to point at the new global
  location instead of `docs/reference/learning.md`.
- New: `$SHMORCH_HOME/../learning/` i.e. `~/.shmorch/learning/` (sibling to
  `~/.shmorch/personal-profile/`, user-owned, not inside the skill repo itself — same reasoning
  as why `personal-profile/` isn't checked into the skill: it's developer state, not skill
  code, and needs to survive skill upgrades/reinstalls untouched).
- `core/documentation.md` — add the global learning log to whatever section documents
  `docs/reference/` conventions, noting the project-local `learning.md` file is retired in favor
  of the global one.

Behavior:
- Capture concepts in `~/.shmorch/learning/<topic-or-index>.md` (single growing file vs.
  one-file-per-concept — worth deciding at implementation time; the existing per-project
  `learning.md` used one-file-many-entries, which scaled fine).
- Each entry keeps a "seen in: `<project>`" list (append the current project name when a concept
  resurfaces there) for provenance, per the original pre-planning proposal.
- Project docs (`docs/reference/index.md` or wherever the project would have linked
  `learning.md`) keep a link back to the global file/entry instead of owning the content.
- Existing per-project `docs/reference/learning.md` files (treeclusion's, and any others written
  before this lands) should be migrated: content moved into `~/.shmorch/learning/`, project file
  either removed or replaced with a pointer, at the next `self-improve`/sync pass that touches
  that project — not automatically, since a skill-repo session has no standing to reach into
  other projects' repos.

**Open, to resolve during implementation** (carried from the original pre-planning note):
- Exact file layout inside `~/.shmorch/learning/` (single file vs. per-topic).
- Dedup behavior when the same concept resurfaces in a second project — append to "seen in" vs.
  treat as a new entry.
- Whether `/shmorch wrap` or another workflow should surface "new global learnings this session"
  in its session-close report, the way file-touched lists already are.

## Improvement

One durable, cross-project record of concepts the developer has already been briefed on —
Sphinx architecture, XSS-vs-parse-location, and whatever comes next — instead of re-explaining
(or worse, silently re-capturing with drift) the same concept in every project's own
`docs/reference/learning.md`. Matches the precedent Claude Code's own memory system already
sets (global + per-project linkback) that the original pre-planning note pointed at.
