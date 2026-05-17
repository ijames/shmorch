# Command: discover

Deep audit of an existing codebase. Fills in `docs/state/context.md` and `docs/state/stack.md` from what's actually in the project — not from guesses.

## When to run
- After `init` on an existing project
- Any time the state files feel stale relative to the real code
- When onboarding to an unfamiliar codebase

## Dispatches to
`workflows/discover.md`
