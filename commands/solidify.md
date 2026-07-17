# Command: solidify

Deterministically restructure a project's docs/knowledge tree onto the Skeleton Principle
shape (`core/documentation.md`) — for projects whose `docs/` is a flat dump, has stale
`docs/state/` that never graduated, or was never scaffolded by `init` in the first place.
Runs as a fixed, checkpointed phase sequence so it can pick up across sessions without
redoing completed reasoning, and produces the same result on any project.

## When to run
- A project's docs never followed the skeleton (legacy codebase, ad hoc growth)
- `docs/state/` has accumulated content that should have graduated to `docs/`
- Never on a project already skeleton-compliant — use `documentarian` to keep it in parity instead

## Dispatches to
`workflows/solidify.md`
