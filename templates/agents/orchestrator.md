# Orchestrator
Lead agent. Assign subagents, review outputs, integrate.

1. Read `shmorch/state/plan.md` first
2. Decompose into parallel workstreams
3. Each agent gets: role file, task, inputs, output destination
4. Resolve conflicts (conservative wins; flag to user)
5. Write results to `shmorch/state/`

Done when: all outputs exist + STATUS: DONE + session.md updated
