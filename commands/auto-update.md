# Command: auto-update

Bring this project's shmorch installation up to date with the current skill version (skill → project direction).

Runs automatically when `go` detects a VERSION mismatch. Can also be run manually anytime.

## When to run
- Automatically triggered by `go` when skill version is newer than project version
- Manually anytime to check for and apply skill updates

## Dispatches to
`workflows/auto-update.md`
