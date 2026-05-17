# Command: wrap

Wrap up the current session — stamp the end time, summarize what happened, and update all state files.

Note: wrap automatically runs self-improve at the end of every session. If self-improve has nothing to report, it exits silently.

## When to run
- When done working for now (end of session)
- After committing changes, before leaving the project
- Any time session state needs to be persisted to git

## Dispatches to
`workflows/wrap.md`
