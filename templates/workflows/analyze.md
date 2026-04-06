# Workflow: Analyze

1. Identify scope (user specifies or infer from task)
2. **Stack analysis first** — before diving into code, read `shmorch/state/stack.md`. If it's empty or outdated, refresh it:
   - Re-read dependency files (`requirements.txt`, `package.json`, etc.) for current versions
   - Check for new constraint files (`runtime.txt`, `.nvmrc`, CI config)
   - Note any packages that have been added or changed since the last snapshot
3. Spawn analysts — parallelize by module/area if large
4. Each analyst writes `state/analysis-<area>-<ts>.md`:
   - Structure summary, healthy code, dead code [CRUFT], blockers [BLOCKER]
   - Flag any usage that's outdated for the detected version or conflicts with stack constraints
   - Specific paths + line numbers; never modify files
5. Synthesize → `state/analysis-summary.md`
6. Present: healthy / broken / dead / **version-mismatched**
7. Update `shmorch/state/stack.md` if the analysis revealed new constraints or better package info
8. **State updates now** — don't wait for wrap:
   - Any architectural insight or constraint worth remembering → append to `shmorch/state/decisions.md`
   - Any blocker or risk that affects open tracks → update `shmorch/state/plan.md` immediately
9. Confirm before Spec or Design
