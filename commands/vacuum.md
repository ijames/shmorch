# Command: vacuum

Scan the project for waste — TODOs, dead code, empty tests — then review findings with the user.

All paths are relative to the project root.

## Step 1 — Run the vacuum tool

```bash
bash shmorch/tools/vacuum.sh
```

This generates a report at `shmorch/state/vacuum-report-TIMESTAMP.md`.

## Step 2 — Read the report

Read the generated report file. Summarize the key findings:
- How many TODOs/FIXMEs/HACKs found, and in which files
- Any empty or near-empty test files

## Step 3 — Triage with the user

For each significant finding, ask the user what to do:
- TODOs that look stale or orphaned: "Delete, keep, or address now?"
- Empty test files: "Delete or stub out?"
- FIXMEs: "Fix now or log as a track?"

One decision at a time — don't dump the whole list at once.

## Step 4 — Act on decisions

For each confirmed action:
- Deletions: confirm with user before removing anything
- New tracks: add to `shmorch/state/plan.md` backlog
- Immediate fixes: do them inline

## Step 5 — Log

Stamp: `bash shmorch/tools/timelog.sh "VACUUM" "brief summary of what was cleaned"`
