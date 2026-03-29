# Command: commit

Track-aware commit. Groups shmorch state separately from project code, and labels code commits with the active track name.

All paths are relative to the project root.

## Step 1 — Read active track

Read `shmorch/state/plan.md`. Note the active track name (the one marked "In progress"). If none, use "general".

## Step 2 — Assess changes

Run in parallel:
- `git status`
- `git diff`
- `git diff --cached`
- `git log --oneline -5`

## Step 3 — Separate shmorch state from project code

Classify each changed file:
- **Shmorch state**: anything under `shmorch/state/`, `shmorch/CLAUDE.md` → one commit
- **Shmorch tooling**: `shmorch/tools/`, `shmorch/.claude/`, `shmorch/workflows/`, `shmorch/agents/` → one commit if changed
- **Project code**: everything else → group by logical concern, labeled with the active track

## Step 4 — Plan commits

Output a numbered list:

```
Planned commits:
1. chore(shmorch): sync state — files: shmorch/state/...
2. fix(track-name): description — files: src/foo.php, src/bar.php
3. config: description — files: .claude/...
...
```

Ask: "Proceed with these N commits?" and wait for confirmation.

## Step 5 — Commit each group

For each planned commit:
1. If anything is staged, run `git reset HEAD` first
2. Stage only the files for this commit: `git add <specific files>`
3. Show `git diff --cached --stat` and the planned message
4. Ask: "Commit N/total: OK?" and wait for confirmation
5. Commit using heredoc format:
   ```
   git commit -m "$(cat <<'EOF'
   type(scope): description

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```
6. Verify with `git log --oneline -1`

## Step 6 — Final status

Show `git log --oneline -N` for the commits made.

## Safety rules

- Never use `git add -A` or `git add .`
- Never commit files that look like secrets (.env, credentials, tokens)
- Never force push or amend published commits
- If a pre-commit hook fails, fix and retry as a NEW commit
