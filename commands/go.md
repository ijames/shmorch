# Command: go

The one entry point. Resolves the skill, detects repo state (fresh / behind / current), provisions if needed (init or sync), then orients and proposes the next move.

## When to run
- Chosen at the session-start prompt (see `shmorch-core.md` "Session Start — Resolve, Then Ask")
- After an interrupted session — detects orphaned SESSION_START and recovers
- Any time you need to re-orient mid-session

## Dispatches to
`workflows/go.md`

## Variants
- `/shmorch go [topic]` — optional topic becomes the timelog SESSION_START detail
