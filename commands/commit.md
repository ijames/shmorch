# Command: commit

Group all changes into logical, independent units and commit them — each with tests, docs, and track updates included. The diff tells you the story; tracks give you context.

All paths are relative to the project root.

---

## Step 1 — Assess changes

Run in parallel:
- `git status`
- `git diff`
- `git diff --cached`
- `git log --oneline -5`

Also read `shmorch/state/plan.md` to know the active track name (marked "In progress"). If none, use "general".

## Step 2 — Group by logical independence

Look at the changes and group them into units where each unit:
- Addresses a single concern (feature, fix, refactor, docs, config, shmorch state, etc.)
- Could stand alone if the other groups weren't present
- Makes sense as a single entry in git history

The track tells you what you were working on, but let the diff tell you how to split it. A track might produce 2-3 commits (e.g., the model, the tests, and a schema migration) — that's fine if they're meaningfully independent. But don't split just to split: code and its tests belong in the same commit.

**Typical groupings:**
- **Feature unit**: code + its tests + its docs + track update → one commit per logical feature
- **Shmorch state only**: `shmorch/state/`, `shmorch/CLAUDE.md` → one commit
- **Shmorch tooling**: `shmorch/tools/`, `shmorch/workflows/`, `shmorch/agents/`, `shmorch/.claude/` → one commit if changed
- **Config/infra**: `.claude/settings.local.json`, CI config, etc. → one commit

## Step 3 — Definition of Done check (per group)

For each code-containing group, verify before committing:

**Tests**
- Any new or changed public method → corresponding test must exist
- If missing: write tests now, or get explicit user sign-off to defer

**Docs**
- Any new public API, architectural change, or new model/exception type → docs must be updated
- Check `docs/architecture/` and `docs/tech/` for the relevant doc
- If missing: update docs now, or get user sign-off

**Track**
- Is this work tied to an open step in `shmorch/tracks/`?
- If yes: mark the step done or update progress in the track file before committing
- If no track exists and this is non-trivial: ask the user if a new track is needed

## Step 4 — Plan and confirm

Output a numbered list:

```
Planned commits:
1. feat(track-name): description — files: biz.py, test_biz.py, docs/api.md, tracks/auth/plan.md
2. chore(shmorch): wrap state — files: shmorch/state/plan.md, shmorch/state/session.md
3. config: description — files: .claude/settings.local.json
```

Ask: "Proceed with these N commits?" and wait for confirmation.

## Step 5 — Commit each group

For each planned commit:
1. If anything is staged, run `git reset HEAD` first
2. Stage only the files for this commit: `git add <specific files>`
   - For partial file changes (only some hunks belong here), use `git add -p <file>`
3. Show `git diff --cached --stat` and `git diff --cached`
4. State the planned message
5. Ask: "Commit N/total: OK?" and wait for confirmation
6. Commit:
   ```
   git commit -m "$(cat <<'EOF'
   type(scope): description

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```
7. Verify with `git log --oneline -1`

## Step 6 — Final status

Show `git log --oneline -N` for the commits just made.

---

## Safety rules

- Never use `git add -A` or `git add .`
- Never commit files that look like secrets (.env, credentials, tokens)
- Never force push or amend published commits
- Never skip hooks (--no-verify)
- If a pre-commit hook fails, fix and retry as a NEW commit
- If tests or docs are missing, do not commit the code alone without explicit user sign-off
