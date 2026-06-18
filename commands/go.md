# Command: go

Enter Shmorch orchestration mode. Read state, orient, and propose the next move.

## When to run
- Chosen at the SessionStart prompt (see `shmorch-core.md` "Session Start — Ask, Don't Auto-Run")
- After an interrupted session — detects orphaned SESSION_START and recovers
- Any time you need to re-orient mid-session

## Dispatches to
`workflows/go.md`

## Variants
- `/shmorch go [topic]` — optional topic becomes the timelog SESSION_START detail
