# Command: checkpoint

Quick-save shmorch state files to git. Use this mid-session to preserve planning state without running a full commit.

## When to run
- Mid-session after significant planning or state changes
- Before a context-heavy operation where you may need to restore
- Any time the working tree has state-only changes you want to preserve

## Steps

### Step 1 — Run checkpoint

```bash
bash ~/.claude/skills/shmorch/tools/checkpoint.sh
```

### Step 2 — Report result

Show the output to the user. If "Nothing to checkpoint." — tell the user the state files are already clean.
If a commit was made, show `git log --oneline -1`.
