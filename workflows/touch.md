---
loads_when: user ran `/shmorch touch` — a silent state-sync, not a session entry point; also
  invoked inline by `wrap` Step 5-6 and `resume` Step 2, which delegate their own reconciliation
  here rather than duplicating it
size: 83 lines
---

# Workflow: touch

Reconcile `session.md`, `plan/`, and the project's track-status listing against reality, then
stop. No SESSION_START/END stamps (this isn't a session boundary), no context interview, no gap
scanning, no summary narration beyond what changed. If nothing's drifted, say so in one line and
stop.

This is the single source of truth for "does session.md / plan/ / track-status match git
reality" — `wrap` and `resume` both call into this workflow instead of re-implementing the
cross-check. Only run this workflow's own Step 3 report when invoked directly as `/shmorch
touch`; when called from `wrap` or `resume`, just return what was reconciled and let the caller
report it in its own voice.

## When to use
- Mid-session, to keep state files honest without invoking `wrap`'s full close-out
- Called inline from `wrap` Step 5-6 and `resume` Step 2 — don't duplicate this logic there

## Inputs
- `docs/project/session.md`, `docs/project/plan/`
- `docs/project/tracks/index.md` — Open/Closed track-status table. If a project doesn't have
  this file yet (some older repos still inline a table in `docs/project/index.md`), flag the
  divergence once rather than silently reconciling the wrong location.
- `git branch --show-current`, `git log --oneline -10`, `gh pr list --state merged --limit 5`
  (best-effort; skip silently if `gh` fails or isn't authenticated)
- `find docs/project -newer docs/project/session.md` — files touched since the last log entry

## Roles
- None — runs inline

---

## Step 1 — Read and cross-check

Read `session.md`, `plan/`, and the track-status listing in parallel, then check: does the
branch match what `session.md` calls "in progress"? Any merged PR or commit not named in the
last entry? Any file under `docs/project/` newer than `session.md` itself? Any track whose
frontmatter `status:` disagrees with its row/line in the project's track-status listing?

## Step 2 — Reconcile, don't rewrite

If nothing drifted: say so in one line (`session.md and plan/ match repo state — nothing to
touch.`) and stop.

If something drifted, apply the minimum edit that makes the docs true again:
- Check off `plan/` items git shows as merged/shipped
- Append one line to `session.md`'s latest entry noting what happened since it was last
  written (commits, merged PRs) — don't rewrite the entry, extend it. When called from `wrap`,
  the caller still owns creating/demoting the dated `## Latest Session` heading and filling in
  the human-sourced sections (Step 3's answer) — this step only handles the git-fact portion.
- Flip a track's `status:` frontmatter if the log confirms it closed, and mirror that flip into
  `tracks/index.md` (move the row from Open to Closed, or vice versa) — a track can drift in
  either direction: frontmatter says Closed but the table still lists it Open, or vice versa.
  Fix whichever is stale against the other plus git.
- Reconcile `plan/index.md`'s **Current Activities** section — this is the drift `touch`
  exists to catch early, since `wrap`'s equivalent step only runs on a full close-out and gets
  skipped when sessions end without one. It's a list, not a single slot: add a line for
  anything newly started, remove or update the line for anything that closed, and don't
  clobber an unrelated concurrent entry (e.g. self-improve running unattended) while updating
  another.
  - Stamp each entry with a last-modified date via `git log -1 --format=%ad --date=short --
    <path>` on the linked track/file — cheap, and more trustworthy than a hand-maintained
    `updated:` frontmatter field, which drifts for the same reason this section did. For an
    entry with no backing file (e.g. "self-improve running unattended"), skip the date.

Don't touch `context.md`, `stack.md`, acceptance criteria, timelog stamps, decisions.md, or
anything else outside `session.md`/`plan/`/track-status — those stay `wrap`-only.

## Step 3 — Report

Only when invoked directly as `/shmorch touch`: one or two lines, what was out of sync, what
got fixed. No re-orientation, no next-step proposal — that's `resume`'s job if the user wants
it next.

When called inline from `wrap` or `resume`, skip this step — return what was reconciled and let
the caller fold it into its own report/next-step language instead of printing a second summary.
