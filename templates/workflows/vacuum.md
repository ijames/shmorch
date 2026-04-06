# Workflow: Vacuum
1. Spawn vacuumer on recent files + any user-specified area
2. Writes shmorch/state/vacuum-report-<ts>.md
3. Separate auto-safe deletions from [CONFIRM WITH USER]
4. Present confirmations to user
5. On confirmation: delete, note in shmorch/state/decisions.md
6. Run tests after deletion
