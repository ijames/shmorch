# Role: pe-synthesizer

Used only by `/shmorch pe` (`workflows/personal-eval.md`) against
`$PERSONAL_PROFILE_HOME` (default `~/.shmorch/personal-profile`), a separate,
non-public repo of persona evidence. Cheap model tier — this is classification against
a fixed 10-section taxonomy, not open-ended reasoning.

## Input
- The session summary just produced by `pe-summarizer` (`sessions/<slug>.md`)
- The raw request/response text for that same session (for spot-checking the summary
  against the source, not just trusting it)
- `profile/index.md` and whichever of the section files listed there the summary's
  anchors point at (read only the sections touched, not all of them)

Never read `<slug>_agent_behavior.md` — separate evidence stream for a distinct,
not-yet-built purpose, out of scope for this role.

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
The profile is a folder of section files, not a single `profile.md` — read
`profile/index.md` for the current file list and per-section gist before touching
anything. Decide, section by section, for each `## <Section Name> {#<anchor>}` heading
the summary contains, whether this session's evidence:

- **Reinforces** an existing bullet in that section's file — add the new session's
  evidence to that bullet's footnote trail (see Citation format below) rather than
  duplicating the claim.
- **Adds** something genuinely new — new bullet in the matching section file, one
  concrete, complete-sentence claim, footnoted to `../sessions/<slug>.md#<anchor>`.
- **Conflicts** with an existing bullet — do not silently overwrite. Add a
  `(tension: <date> — <what conflicts>)` note next to the existing bullet. A profile
  that hides contradictions is less useful than one that shows the person changes or
  is inconsistent in a specific, named way.

Do not invent traits the session doesn't support. Thin sessions may add nothing —
that's a valid outcome, not a failure.

**Sections other than `{#track-record}` hold *only* James's own decisions,
direction, judgment calls, and review catches — never the technical work the
assistant did to carry them out.** A bullet earns a place in one of these files
only if the summary shows James actually deciding, directing, scoping, catching,
or reviewing something — check the `[James]`/`[Agent]` tags `pe-summarizer`
attached; only `[James]`-tagged material is eligible. It names the concrete
decision *and* what that decision demonstrates about him, never the how of the
AI's execution (no code paths, no debugging narrative, no
"runs/builds/traces/fixes" with James as the implied subject when the tag says
`[Agent]`). If a session is pure `[Agent]`-tagged execution with no
`[James]`-tagged directorial judgment, it contributes no bullet to these files —
that's expected, not a gap.

`{#track-record}` gets different treatment. `profile/track-record.md` is kept
literal — project name, what shipped, date, outcome — the same specifics the other
sections deliberately strip out. Reinforces/Adds/Conflicts still apply (e.g. a later
session reporting a project shipped is an update to an earlier "in progress" entry,
not a duplicate), but don't paraphrase a concrete fact into trait language just to
match the other sections' voice.

**The taxonomy is mutually exclusive and collectively exhaustive.** Every piece of
evidence you decide is genuinely worth keeping lands in exactly one file — never
split the same fact across two sections, and never leave a fact you've judged worth
keeping unfiled. If a fact doesn't fit any of the 10 taxonomy sections after
genuinely trying (not just the first section you checked) — or a `[James]`-tagged
fact doesn't cleanly resolve to one of the 6 O*NET-adapted categories, work styles,
values, or the other non-O*NET additions — write it to
`profile/ambiguous-uncategorized.md` instead, same footnote/citation format as any
other bullet, kept literal like `track-record` rather than compressed into trait
language (compressing an ambiguous fact into generalized prose would hide exactly
what made it hard to place). **Flag it**: end your output/commit message with a
line stating the count of ambiguous entries added this session, e.g. `AMBIGUOUS: 1
entry added to ambiguous-uncategorized.md — needs a human look`, so the batch
report in `workflows/personal-eval.md` Step 4 can surface it to the user rather
than it going unnoticed in a routine commit.

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
preview line and bullet count for any section you touched (see the file's own
"Sections" list format) — the index must stay a truthful preview, not go stale.

**Replace the preview, don't append to it.** This is a hard cap: one sentence,
~150 characters, describing the section's overall character right now — not a
running list of every distinctive bullet ever added. If the existing preview is
already a comma-spliced list from past sessions accreting onto it, that's the bug
this rule exists to stop — collapse it back to one sentence rather than adding a
53rd clause. A reader opens the linked file for specifics; the preview's only job
is "should I open this file," not "here is everything in it."

If your changes materially shift the "At a glance" paragraph's claims, update that
too; otherwise leave it.

## Output
- Updated section file(s) for whichever sections were touched, plus
  `profile/index.md` if its preview text is now stale.
- `git add` the session summary file itself (`sessions/<slug>.md`) along with
  everything else in the same commit — it's an input you read, not something
  already tracked, and leaving it untracked breaks the profile's provenance trail.
- `git commit` inside `$PERSONAL_PROFILE_HOME` (local-only repo, no remote) with a
  message naming the session id and a one-line summary of what changed — this is the
  profile's version history. If nothing changed, still commit a no-op-noting commit or
  skip, but say so.
- Append a row to `stats.md` (session, date, project, start–end, duration, categories
  touched) and update its tally counts, per `README.md` § Structure.
- Run `python3 $PERSONAL_PROFILE_HOME/tools/scan.py --mark <path>` to close out the session
  in the ledger, where `<path>` is the original transcript `.jsonl` path (not the
  slug, not the summary filename) — `scan.py` derives the ledger's session id from
  that path's basename itself. Never append to `processed.log` by hand; if you don't
  have the original transcript path, ask for it rather than writing the slug in.
