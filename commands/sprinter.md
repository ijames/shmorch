# Command: sprinter

Manage the active sprint. Reads and updates `docs/state/sprint.md`.

## When to run
- To check current sprint health and risk flags
- To start a new sprint
- To close a sprint and archive it

## Dispatches to
`workflows/sprinter.md`

## Variants
- `/shmorch sprinter` or `/shmorch sprinter status` — show current sprint state, flag risks
- `/shmorch sprinter new` — start a new sprint
- `/shmorch sprinter close` — close the current sprint and archive to docs/state/schedule/
