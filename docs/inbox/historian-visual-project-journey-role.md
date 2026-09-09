# Candidate role: `historian` — visual/narrative project journey capture

**Status:** Promoted 2026-09-08 to
`docs/project/tracks/20260908-historian-role/index.md` — high-level scoping
(two-role pipeline, output locations, manual-only triggers) done there. This
file stays as the original capture for context; further work happens in the
track.

**Filed from `shmorch` (self)**, developer request: "capture this and add it to
the list to do."

## The idea

A new Shmorch role, `historian`, that builds a project's story over time —
beyond commits/tags/tracks — combining plain-language descriptions and
decisions with diagrams, visuals, and (for projects with a UI) screenshots of
the app as it matures. Developer's framing: "I've been missing the evolution
of all my tools and there's definitely a story and material for everything
I'm doing here for publication and sharing." Automating the capture is the
point — doing this by hand doesn't scale and the curating burden is why it
isn't happening today.

Two capture modes:
- **Forward-running**: capture screenshots/diagrams as a project evolves
  (e.g., at merge points going forward).
- **Retroactive**: jump to key past merge points (via git) and recapture
  screenshots of the app as it looked then, to backfill history that was
  never captured live.

## Priority

Most important for **DarkBadge** and **Treeclusion** — developer said these
"need articles to go with them," implying the near-term goal is publishable
narrative pieces, not just an internal archive.

Applies to any Shmorch project with a visual/UI surface: Paths, Treeclusion,
DarkBadge, Mobos, Shming, Time Vortex (named explicitly by the developer).

## Side pursuit (separate, smaller scope — do not conflate with the above)

Reviewing decisions and analyses made along the way and calling out the
*research* behind them as part of the same narrative — distinct from the
screenshot/visual capture mechanism itself. Likely a separate pass over
existing `docs/project/decisions/` and analysis artifacts rather than new
automation.

## Not resolved — needs real scoping before building

- Screenshot mechanism: likely `claude-in-chrome` browser automation
  (navigate + screenshot) driven per-project, but needs a trigger model (on
  merge? on a schedule? on `wrap`?) and a storage location convention (a
  `docs/history/` or per-project `screenshots/` directory?).
- Retroactive mode requires checking out historical commits/tags and running
  the app locally at each point — meaningfully harder than forward capture
  (build/run environment may not still work at old commits); may need to be
  scoped as opportunistic/best-effort rather than guaranteed.
- Where the resulting narrative lives — a new `docs/history.md` per project,
  or an actual published article draft — and whether `historian` writes prose
  itself or just assembles the evidence (commits, decisions, screenshots) for
  the developer to write from. Likely the latter, consistent with this
  developer's preference elsewhere for capturing evidence over having Shmorch
  draft prose in his voice: assemble evidence, don't ghostwrite the article.
- Explicitly flagged by the developer as "not an easy task" — this needs a
  proper scoping/design pass (its own track, likely under DarkBadge and/or
  Treeclusion first as the priority pair) before any building starts.
