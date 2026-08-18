# Command: learn

`/shmorch learn <thing to remember>` — user-directed capture: save knowledge exactly
where the developer points, right now, instead of waiting for the agent to notice a gap.

Run with no args inside `$SHMORCH_HOME` itself: audit mode instead of capture — check
that existing learning files are reasonable size, shape, and meaning (not a promotion or
migration pass, just a lint).

## When to run
- Manually, any time the developer wants to save something on the spot: `/shmorch learn <text>`
- No args, in the shmorch repo: periodic health check on the learning corpus

## Dispatches to
`workflows/learn.md`
