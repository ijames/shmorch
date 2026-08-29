---
loads_when: the developer raises a thought mid-session that's out of scope for the
  current task and worth capturing for later triage
size: 45 lines
---

# Workflow: aside

Turn a raw, mid-session thought into a `docs/inbox/` item `check-inbox` can act on
later — without derailing the current task into a full scoping session.

## Inputs
- The raw thought(s) just raised, from context (don't ask the developer to repeat it)
- `docs/inbox/*.md` (or `$SHMORCH_HOME/docs/inbox/*.md` for SELF) — existing items, so
  a new one doesn't duplicate one already filed

## Step 1 — Split or coalesce

If the developer raised multiple distinct asides in one breath, coalesce them into a
single file with sub-headings rather than one file per item — don't fragment a single
train of thought into several inbox entries.

## Step 2 — Mini-interview (one question at a time)

Only enough to make the item actionable later, not to fully scope it now:
- Does this relate to or extend an existing inbox item, plan item, or track? (quick
  grep against `docs/inbox/`, `docs/project/plan/`, `docs/project/tracks/` first —
  don't ask if it's obviously already covered)
- Anything about the gap or suggested direction the developer wants captured beyond
  what they already said?

Stop there. This is not a build interview — if the developer wants to keep talking
about it, that's a scoping session, not `aside`.

## Step 3 — Write the item

`docs/inbox/<slug>.md` (or `$SHMORCH_HOME/docs/inbox/<slug>.md` for SELF), matching
the existing inbox file shape — title, context/gap, suggested direction if any. Not a
full spec.

## Step 4 — Update the index

`docs/inbox/index.md` — add a line under **Open:** for the new item(s), matching the
existing entries' format (filed-from project, date, one-line synopsis).

## Step 5 — Return control

No further prompting. Confirm the file was written in one line and go back to
whatever the developer was doing before the aside.
