---
loads_when: triaging docs/inbox/ — act now or defer, per item
size: 95 lines
---

# Workflow: check-inbox

`docs/inbox/` is a drop zone, not a destination. Items sit there until someone decides
where they actually belong. This workflow makes that decision explicit, one item at a
time, instead of letting the folder grow until `self-improve` happens to glance at it.

This is deliberately narrower than `self-improve`: it doesn't hunt for friction
patterns in session history — it only processes what's already sitting in the inbox.
`self-improve` still gates on real session evidence for *proposing* new items; this
workflow just clears what's already there.

## Inputs
- `docs/inbox/*.md` (project) — or `$SHMORCH_HOME/docs/inbox/*.md` if this is the
  skill's own repo (`$SHMORCH_SELF=1` or cwd is `$SHMORCH_HOME`) and it has no
  project-level inbox of its own
- `docs/project/plan/` (or `$SHMORCH_HOME/docs/project/plan/` for SELF) — existing
  backlog, so a new item doesn't duplicate one already tracked
- `docs/reference/` — existing reference material, same duplicate check
- `docs/project/pre-planning.md` if present (SELF-repo convention for "captured, not
  scoped" ideas — see `core/documentation.md` if this file doesn't exist elsewhere;
  don't invent it for a project that doesn't already use it)

---

## Step 1 — List items

```bash
ls docs/inbox/*.md 2>/dev/null | grep -v index.md
```
No project inbox and this is SELF → fall back to `$SHMORCH_HOME/docs/inbox/*.md`.
Nothing found either way → tell the developer "Inbox is empty." and stop.

## Step 2 — Classify each item (mechanical check first)

For each file, grep its core concern against current state before asking the
developer anything — don't waste their attention on something already handled:

```bash
grep -rl "<keyword from the item>" docs/project/plan/*.md docs/reference/**/*.md \
  docs/project/pre-planning.md $SHMORCH_HOME/workflows/*.md $SHMORCH_HOME/shmorch-core.md 2>/dev/null
```

- **Already covered** (found substantively elsewhere) → tell the developer where, confirm
  deletion, remove the file. No further step needed for this item.
- **Not found** → continue to Step 3.

## Step 3 — Ask: act now or defer

Present one item at a time:

> "Inbox: **\<title>**
> \<1-2 sentence synopsis>
> Act now (draft it into \<proposed destination>) or defer (leave it, mark reviewed)?"

Propose a destination based on the item's own content — don't force a single shape:
- Reads like lookup/how-to material with no open decision → `docs/reference/` (or
  `docs/reference/instructions/` if it's a how-to)
- Reads like a scoped, ready-to-build backlog item → `docs/project/plan/<slug>.md`
  with `status: open` / appropriate `category` frontmatter, matching sibling files in
  that directory
- Reads like a real feature needing its own work log → a track:
  `docs/project/tracks/YYYYMMDD-<slug>/index.md` from
  `templates/.shmorch/docs/track-template.md`
- Reads as genuinely unscoped / "worth revisiting if X happens" (the item says as
  much, e.g. "not scoped," "loose," "thinking out loud") → **defer**, don't force it
  into a backlog shape it doesn't have yet. For SELF, `docs/project/pre-planning.md`
  is the existing home for this shape — append a new `##` section there, matching its
  established per-idea format (prompted-by date, the thought, not-scoped closing
  line). For a regular project without an equivalent file, defer in place instead of
  inventing one.

**Act now:**
1. Write the destination doc, folding in the item's content (don't just copy-paste —
   integrate against what's already at that destination, matching its structure and
   avoiding duplication like the "pe multi-source ingestion" precedent in shmorch's own
   `pre-planning.md`, where a later inbox item was merged into an already-larger existing
   section rather than added as a second entry).
2. Remove the inbox file.

**Defer:**
1. If the file doesn't already state a status, prepend one: `**Status:** Deferred
   <date> — <trigger to revisit>`.
2. Leave the file in `docs/inbox/`.

## Step 4 — Update the index

`docs/inbox/index.md` lists every remaining file. Regenerate the list to match what's
actually still present — don't hand-track drift between the two.

## Step 5 — Stamp

```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "check-inbox: <N acted, M deferred, K already-covered>"
```

If run standalone (not from `go` or `self-improve`), also append one line to
`docs/project/session.md`: `check-inbox <date>: N acted, M deferred.`
