# Workflow: Spec
1. Spawn specwriter with task + analysis summary + user decisions
2. Overwrites shmorch/state/spec.md
3. Resolve all [UNCLEAR] with user
4. Iterate until approved
5. Log each decision to `shmorch/state/decisions.md` **as it's made** during iteration — not all at the end
6. If this spec supersedes an earlier one or countermands prior decisions: rewrite those entries to current reality. Note date and reason; don't append a correction on top of stale content.
7. Proceed to Design or Build
