# Command: check-inbox

Triage `docs/inbox/` — for each captured item, decide with the developer whether to
act now (graduate it into the right doc: reference material, a plan/backlog item, or
a full track) or defer (leave it in place, explicitly marked as reviewed).

## When to run
- Automatically at session start (`go`), surfaced as a non-blocking prompt when
  `docs/inbox/` has items
- Manually any time `docs/inbox/` has accumulated items and you want to clear it

## Dispatches to
`workflows/check-inbox.md`
