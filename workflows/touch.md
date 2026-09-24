---
loads_when: user ran `/shmorch touch` — a silent state-sync, not a session entry point; also
  invoked inline by `wrap` Step 5-6 and `resume` Step 2, which delegate their own reconciliation
  here rather than duplicating it
size: 115 lines
---

# Workflow: touch

Reconcile `session.md`, `plan/`, `sprint.md`, and the project's track-status listing (including
whether each closed track's knowledge actually graduated to its `→ destination` doc) against
reality, then stop. No SESSION_START/END stamps (this isn't a session boundary), no context
interview, no gap scanning, no summary narration beyond what changed. If nothing's drifted, say
so in one line and stop.

This is the single source of truth for "does session.md / plan/ / sprint.md / track-status
match git reality" — `wrap` and `resume` both call into this workflow instead of
re-implementing the cross-check. Only run this workflow's own Step 3 report when invoked
directly as `/shmorch touch`; when called from `wrap` or `resume`, just return what was
reconciled and let the caller report it in its own voice.

## When to use
- Mid-session, to keep state files honest without invoking `wrap`'s full close-out
- Called inline from `wrap` Step 5-6 and `resume` Step 2 — don't duplicate this logic there

## Inputs
- `docs/project/session.md`, `docs/project/plan/`, `docs/project/sprint.md` (or
  `docs/project/schedule/sprint.md` — either location, if present)
- `docs/project/tracks/index.md` — Open/Closed track-status table. If a project doesn't have
  this file yet (some older repos still inline a table in `docs/project/index.md`), flag the
  divergence once rather than silently reconciling the wrong location.
- Each track's own `index.md` frontmatter (`Status:`/`status:`) and `→ destination` header, for
  every track this run's Step 2 flips to Closed
- `git branch --show-current`, `git log --oneline -10`, `gh pr list --state merged --limit 5`
  (best-effort; skip silently if `gh` fails or isn't authenticated)
- `find docs/project -newer docs/project/session.md` — files touched since the last log entry

## Roles
- None — runs inline

---

## Step 1 — Read and cross-check

Read `session.md`, `plan/`, `sprint.md`, and the track-status listing in parallel, then check:
does the branch match what `session.md` calls "in progress"? Any merged PR or commit not named
in the last entry? Any file under `docs/project/` newer than `session.md` itself? Any track
whose frontmatter `status:` disagrees with its row/line in the project's track-status listing?
Does `sprint.md` name a PR number, milestone, or date meaningfully behind the latest merged PR /
`git log` tip (rule of thumb: sprint.md itself says it's stale, or the gap is large enough that
half its content no longer matches current track/PR state)?

**Plan/ pruning is paused — do not check off, move, or delete any `plan/` item's line,
`[x]` or not, until `docs/inbox/plan-item-graduation-undefined.md` resolves.** A prior version
of this step archived `[x]` lines into `plan/completed-tasks.md`, and the developer using it
found that plan-item lines routinely carry the only surviving implementation detail (commit
hashes, exact behavior, rationale) — nothing else graduates that detail the way a track's
`→ destination` doc does. Pruning silently threw it away. Leave `plan/` alone in this step
until that item names a real graduation path for plan items.

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
  Fix whichever is stale against the other plus git. This is also the mandatory post-merge step
  from `core/git-discipline.md` — don't treat it as optional cleanup, it's the primary reason
  this drift check exists.
  - **Graduation check, every time a track flips to Closed here:** read that track's
    `→ destination` header and check whether the named `docs/<category>/` doc(s) were actually
    touched (`git log -1 --format=%ad -- <destination path>` at or after the track's closing
    commit). If the destination wasn't touched, don't write the graduation yourself — flag it
    by name in the Step 3 report and leave the track's own `Open decision`/`Next step` field
    noting the gap, so it surfaces on the next `resume` instead of silently going stale. Writing
    the actual product/technology content is `documentarian`'s job (deeper, does the integration
    itself); `touch` only catches that it didn't happen.
- ~~Prune plan/~~ — **paused**, see the Step 1 note above. Do not act on this until
  `docs/inbox/plan-item-graduation-undefined.md` resolves.
- Flag (don't rewrite) a stale `sprint.md`: one line in the Step 3 report naming what it still
  claims vs. current reality (e.g. "sprint.md cites PR #96, main is at #248"). Actually
  reconciling sprint.md's content is out of scope for `touch` — that's project-specific
  scheduling work, not a state-sync fact-check, and some projects (sprint tracking unused)
  may never want it rebuilt at all. Surfacing the gap here just keeps it from being trusted by
  accident; whether/how to fix it stays a developer call, tracked in that project's own
  backlog if they want it addressed.
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

Only when invoked directly as `/shmorch touch`: one or two lines per category, what was out of
sync, what got fixed — plus anything Step 2 flagged rather than fixed (an ungraduated track
destination, a stale sprint.md) named explicitly so it doesn't get lost. No re-orientation, no
next-step proposal — that's `resume`'s job if the user wants it next.

When called inline from `wrap` or `resume`, skip this step — return what was reconciled and let
the caller fold it into its own report/next-step language instead of printing a second summary.
