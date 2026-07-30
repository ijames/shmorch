↑ [Inbox](index.md)

# init — settings.json explanation

**Issue (2026-04-01):** During `/shmorch init`, the user paused when Claude wrote `.shmorch/.claude/settings.json` and asked why it was needed. The init command doesn't explain the purpose of any files it creates.

**What to consider:**
- Add a brief explanation in Step 3 of `commands/init.md` or in Step 7 (the report) describing what `.shmorch/.claude/settings.json` does: it wires up pre-tool safety hooks (blocks `rm -rf`, `git push --force`) and pre-allows common read-only commands.
- Alternatively, add a `## What Got Created` section to the Step 7 report so users understand what they're getting.
- The user was fine proceeding once explained — this is a "explain proactively" gap, not a design problem.
