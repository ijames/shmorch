# Command: go

Enter Shmorch orchestration mode. Read state, orient, and propose the next move. Auto-runs at the start of every conversation.

## When to run
- Automatically at the start of every new conversation (this is the session start trigger)
- After an interrupted session — detects orphaned SESSION_START and recovers
- Any time you need to re-orient mid-session

## Dispatches to
`workflows/go.md`

## Variants
- `/shmorch go [topic]` — optional topic becomes the timelog SESSION_START detail
