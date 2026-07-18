# Workflow: Vacuum

Find waste. Report before deleting. Run after build, or on demand.

## When to use
- After completing a build (mandatory before committing)
- When TODOs, dead tests, or orphaned docs are suspected
- On demand via `/shmorch vacuum`

## Inputs
- Files changed in the last 10 commits (default scope)
- Or user-specified area

## Roles
- None — runs inline

---

## Step 1 — Scope

User specifies area, or default to: files changed in the last 10 commits and their direct neighbors (files they import or that import them).

---

## Step 1.5 — Untracked file scan

```bash
git status --porcelain | grep '^??' | awk '{print $2}'
```

For each untracked file not covered by `.gitignore` and not part of the expected scaffold, check `docs/state/vacuum-report-*.md` from prior runs (or session.md "next up" notes) for whether this same path was already flagged. If it was flagged in 2 or more prior vacuum passes and still exists: escalate — do not add it as another "next up" note that can silently drop. Instead, create a named backlog item (a track stub or a `docs/state/plan.md` entry) with the file's provenance if known, and say so explicitly to the user: "`<path>` has survived N vacuum passes — opening it as a backlog item instead of re-flagging."

---

## Step 2 — Reference check (before flagging anything dead)

For every candidate item, verify references **before** classifying it:
- `grep -r` / ripgrep for all usages: `require_once`, class name, method name, constant name
- Check test files for direct coverage
- Check `docs/architecture/` for documentation references
- Check `docs/state/context/*.api.md` for API surface entries

**Do not flag something as dead unless you've confirmed zero external references.**

---

## Step 3 — Classify findings

| Category | Auto-safe | Criteria |
|----------|-----------|---------|
| Commented-out code blocks > 10 lines | Yes | No reference to the contained logic anywhere active |
| Stale TODO comments | Yes | Refers to work that's already done or explicitly descoped |
| Unreferenced files | Yes | Zero `require_once` / `use` / `include` hits across codebase |
| Empty test methods (zero assertions) | Yes | Clearly a placeholder with no assertion body |
| Duplicate test assertions | **Confirm** | May have intent; check commit context |
| Unused class properties | **Confirm** | May be set dynamically via magic methods or reflection |
| Public methods with no callers | **Confirm** | May be external API surface or future hook |
| Stale docs (wrong paths, wrong method names) | **Confirm** | Verify against current code before flagging |
| Anything in a live code path | **Never** | Always confirm, no exceptions |

---

## Step 4 — Write report

Write `docs/state/vacuum-report-<timestamp>.md`:
- **Auto-safe:** path + reason + lines saved
- **[CONFIRM]:** path + reason + specific risk if deletion is wrong
- **Estimated total reduction:** lines and files
- Do not delete anything yet

---

## Step 5 — Surface candidates

Before taking any action, present the full candidate list to the user in a table:

```
Category              | File / Location         | Action needed
----------------------|-------------------------|---------------
Commented-out code    | src/api/old-handler.ts  | Auto-safe — delete?
Stale TODO            | app/worker/queue.py:42  | Auto-safe — delete?
Unused class property | app/api/models.py       | [CONFIRM]
Public method, 0 callers | app/api/routes.py   | [CONFIRM]
```

Say: "Found N candidates. Auto-safe: X. Needs confirmation: Y. Want me to proceed?"

Do not delete anything at this step.

## Step 6 — Execute

1. Present auto-safe items as a batch — user can approve or skip
2. Present [CONFIRM] items **one group at a time**, never all at once
3. On confirmation: delete
4. **After each deletion batch: run the full test suite.** If tests fail, stop — do not proceed to the next batch. Diagnose and fix before continuing.
5. Log all confirmed deletions to `docs/development/decisions.md` with date, path, and reason
6. Auto-safe deletions: execute first, then report what was removed
