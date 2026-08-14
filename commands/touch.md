# Command: touch

Silent state sync. Checks `session.md` and `plan/` against actual repo state (git log, branch,
merged PRs) and updates them if they've drifted — no interview, no timelog stamps, no
re-orientation output. Not a session entry point.

## When to run
- Between other work, to keep state files honest without the ceremony of `go`/`resume`/`wrap`
- Before ending a session that doesn't warrant a full `wrap`
- Any time docs might be stale and you just want them fixed, not narrated

## Dispatches to
`workflows/touch.md`

## Variants
- `/shmorch touch` — no arguments
