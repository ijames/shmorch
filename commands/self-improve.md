# Command: self-improve

Retrospective self-improvement **for the current repo** — reads this project's session
history and timelog to surface friction patterns, then proposes changes to this
project's own `.shmorch/` overrides. If a pattern actually points at a gap in the
shmorch skill itself (not just this project), it suggests filing it to shmorch's inbox
rather than applying anything here — see `core/operations.md` § Cross-repo discipline.

Runs automatically at the end of every `/shmorch wrap`. Developer reviews and confirms every proposed change before anything is written.

## When to run
- Automatically at the end of every `wrap` session
- Manually after a frustrating session, after a sprint closes, or when docs/inbox/ has accumulated items

## Dispatches to
`workflows/self-improve.md`
