# Track Template

Copy this to `docs/state/tracks/YYYYMMDD-<track-name>/index.md` when starting a new track.
The date prefix keeps tracks in chronological order and makes the history scannable.
Fill in the two header links first — they are the track's address in the doc tree.

---

```markdown
---
status: Active
updated: YYYY-MM-DD
summary: <one line — what this track is currently doing, kept current as it changes>
---

↑ [<source doc title>](<relative path to source doc>)
→ [<destination doc title>](<relative path to destination doc>)

# Track: <Name>

**Status:** Active
**Started:** YYYY-MM-DD
**Domain:** <domain from docs/architecture/domains.md>

## Why

One paragraph: the product or architectural reason this track exists.
What problem does it solve for the trader, or what structural gap does it close?
Link to the requirement or stable doc that motivated this work.

## What changes

Which stable docs will be updated when this track closes, and what they'll gain.
Be specific: "adds verified OCO payload structure to order-workflow.md" not "updates docs".

## Work log

Findings, decisions, probe results as they accumulate. Write here in the moment —
don't batch at the end.

### YYYY-MM-DD

...
```

---

## Keeping the front-matter current

Update `status`/`updated`/`summary` whenever the track's state changes materially — same
discipline as any `docs/state/*.md` file. `bash $SHMORCH_HOME/tools/track-graph-audit.sh`
flags any track file missing this block or grown past the single-responsibility line cap.

## Filling in the header links

**`↑ source`** — the stable doc this track branches from. Usually a `docs/architecture/`
or `docs/product/` document. Pick the most specific ancestor that directly motivated
this work. If a spec in `docs/state/` spawned the track, point to the stable doc the
spec derives from, not the spec itself.

**`→ destination`** — where the durable findings land when the track closes. Usually
the same as the source, plus any new docs this track will create. Be explicit: if you
plan to create a new doc, name it now (e.g. `new docs/development/schwab-order-api.md`).

If you don't know the destination yet, that's a signal the track isn't scoped — figure
it out before starting.

## Closing a track

When the track closes:

1. Update `**Status:**` to `Closed` and add `**Closed:** YYYY-MM-DD`
2. Write the durable findings into every `→ destination` doc listed in the header
3. Update `docs/state/plan.md` — move the track item from Open to Completed
4. The track directory **stays in `docs/state/tracks/`** — it is project management history, not documentation
5. Run `/shmorch documentarian` to verify the knowledge landed in the right docs sections

**Important:** tracks are project management artifacts. The knowledge they produce distributes into `docs/` sections (product/, architecture/, development/, reference/). There is no `docs/tracks/` — state has tracks; docs don't. The `→ destination` header tells you exactly where each piece goes.
