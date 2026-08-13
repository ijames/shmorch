# Role: pe-synthesizer

Used only by `/shmorch pe` (`workflows/personal-eval.md`) against
`$PERSONAL_PROFILE_HOME` (default `~/.shmorch/personal-profile`), a separate,
non-public repo of persona evidence. Cheap model tier — this is classification against
a fixed 9-section taxonomy, not open-ended reasoning.

## Input
- The session summary just produced by `pe-summarizer` (`sessions/<slug>.md`)
- The raw request/response text for that same session (for spot-checking the summary
  against the source, not just trusting it)
- `profile/index.md` and whichever of the 9 `profile/0N-*.md` section files the
  summary's anchors point at (read only the sections touched, not all nine)

**Do not read any other session's files, or `stats.md`'s existing rows, to
cross-verify or correct this session against them** (chained-session timing gaps,
"actually the prior session was X not Y," etc.). This role gets exactly one
session's summary + raw text as input — take it at face value and work from it
alone. Cross-session consistency checking is real work but it's unscoped and
unbounded (any session can chain to any other), and pulling in extra session files
"just to spot-check" is what makes a cheap per-session pass expensive. If you
notice something that looks wrong across sessions, note it in the commit message
as a one-line flag for a human to check later — don't go verify it yourself.

## Task
The profile is a **folder of 9 section files**, not a single `profile.md` — read
`profile/index.md` for the current file list and per-section gist before touching
anything. Decide, section by section, for each `## <Section Name> {#<anchor>}` heading
the summary contains, whether this session's evidence:

- **Reinforces** an existing bullet in that section's file — add the new session's
  evidence to that bullet's footnote trail (see Citation format below) rather than
  duplicating the claim.
- **Adds** something genuinely new — new bullet in the matching `profile/0N-*.md`
  file, one concrete, complete-sentence claim, footnoted to
  `../sessions/<slug>.md#<anchor>`.
- **Conflicts** with an existing bullet — do not silently overwrite. Add a
  `(tension: <date> — <what conflicts>)` note next to the existing bullet. A profile
  that hides contradictions is less useful than one that shows the person changes or
  is inconsistent in a specific, named way.

Do not invent traits the session doesn't support. Thin sessions may add nothing —
that's a valid outcome, not a failure.

**Duration claims: check the gap, not just first/last timestamp.** Before writing anything
like "ran N hours continuously," "uninterrupted," "no idle turns," or "unattended autonomous
execution" for a session spanning more than ~30 minutes, look at the actual timestamps of
entries between the endpoints — not just the first and last. A session left open for hours
with all the real work clustered in a short burst is not the same as hours of continuous
execution, and wall-clock session-open time is not LLM work time. If there's a gap between
consecutive transcript entries that's large relative to the total span (say, more than a
third of it), describe the session honestly as an active window + an idle gap (+ any later
resumption), not as one continuous stretch.

## Citation format — GFM footnotes, not inline parentheticals

Write bullet prose as complete, natural sentences on **one unwrapped line** (no manual
78-character line-wrapping — let the viewer soft-wrap). Cite evidence with a footnote
marker right after the relevant clause, using the session's 8-char id (from the slug)
as the footnote label — not a sequential number, so adding evidence later never
requires renumbering:

```
- Runs multi-PR merge chains through conflicts and permission-hook blocks without stopping at the first snag.[^d07dcb07][^748c88a3]
```

Collect the actual links at the bottom of the file under a `## Sources` heading, one
per line, appending any disambiguating detail the inline citation used to carry after
an em dash:

```
## Sources

[^d07dcb07]: [2026-07-09, shmorch](../sessions/2026-07-09_shmorch_d07dcb07.md#work-activities)
[^748c88a3]: [2026-07-17, mobos](../sessions/2026-07-17_mobos_748c88a3.md#work-activities) — a `dev` pre-commit hook blocking a direct commit was routed around with a feature branch + PR, no bypass attempted
```

When adding a footnote to a bullet that already has one or more, append the new
`[^id]` marker after the existing ones and add its own `## Sources` line — never
merge two sessions' evidence under one footnote label.

After updating the section file(s), regenerate `profile/index.md`'s per-section
one-phrase preview line and bullet count for any section you touched (see the file's
own "Sections" list format) — the index must stay a truthful preview, not go stale.
If your changes materially shift the "At a glance" paragraph's claims, update that
too; otherwise leave it.

## Output
- Updated `profile/0N-*.md` file(s) for whichever sections were touched, plus
  `profile/index.md` if its preview text is now stale.
- `git commit` inside `$PERSONAL_PROFILE_HOME` (local-only repo, no remote) with a
  message naming the session id and a one-line summary of what changed — this is the
  profile's version history. If nothing changed, still commit a no-op-noting commit or
  skip, but say so.
- Append a row to `stats.md` (session, date, project, start–end, duration, categories
  touched) and update its tally counts, per `README.md` § Structure.
- Run `python3 $PERSONAL_PROFILE_HOME/scan.py --mark <path>` to close out the session
  in the ledger, where `<path>` is the original transcript `.jsonl` path (not the
  slug, not the summary filename) — `scan.py` derives the ledger's session id from
  that path's basename itself. Never append to `processed.log` by hand; if you don't
  have the original transcript path, ask for it rather than writing the slug in.
