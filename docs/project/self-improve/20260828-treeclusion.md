### Self-Improve Proposals — 2026-08-28 | Project: treeclusion

#### Proposal 1: `prioritize` workflow's own instrumentation isn't being followed
**Pattern:** Both times `/shmorch prioritize` has run in this project, the workflow's own
required steps were skipped: Step 1/Step 6's `timelog.sh "PHASE" "prioritize: ..."` stamps are
missing from the ledger, and Step 6's "present and confirm" outcome (apply/adjust/keep) was
never recorded against the proposal.
**Frequency:** 2/2 runs.
- 2026-07-28: `docs/project/timelog.md` has `PHASE | prioritize: starting` (line 30) with no
  matching `complete` stamp ever appended. `docs/project/prioritizer/index.md` records this run's
  status as "Superseded (backfilled 2026-08-08; no record of whether this run's order was
  applied)" — i.e. Step 6 never happened or was never logged.
- 2026-08-18: `docs/project/prioritizer/20260818_priority-proposal.md` exists (proposal was
  produced) but the timelog has zero `PHASE | prioritize` entries anywhere near that date (checked
  lines 43-45, which show `check-inbox`, `SESSION_START`, `SESSION_END` only). The index row for
  this run still reads "Pending decision" ten days later, as of 2026-08-28.
**File:** `workflows/prioritize.md`
**Change:** Add a gate at the top of Step 6 that refuses to let the workflow end without one of
the three outcomes (apply/adjust/keep) recorded in `prioritizer/index.md`'s Status column — the
workflow should not be considered "done" with an unresolved row. Also add an explicit assertion
after Step 1 and Step 6 that the timelog stamp actually landed (read back the last line, don't
just fire-and-forget the `timelog.sh` call), since both stamps have gone missing in practice
despite being scripted steps.
**Improvement:** Closes the gap between "the workflow file says do X" and "X is verifiably in the
ledger" — right now `prioritize` is silently degrading to "write a proposal file and never revisit
it," which defeats the workflow's purpose (re-ranking so blocked/stale work gets decided, not just
catalogued).

#### Proposal 2: no staleness nudge for accumulating Blocked tracks
**Pattern:** `docs/project/tracks/index.md` currently has 16 of 49 tracks (33%) marked "Blocked"
— most commonly "pending scoping session" or "pending decision on whether to pursue at all."
Several have sat blocked since late July with no revisit: `20260722-nonbrowser-canvas`,
`20260723-navigation-heatmap-journal`, `20260723-shmorch-docs-navigator`,
`20260723-stretchtext-theory-research`, `20260723-synced-heading-nav-panel`,
`20260725-page-addressing-model`, `20260728-obsidian-plugin` — a month-plus with zero movement.
The deferred-intent rule (`shmorch-core.md`) correctly stubs a track the moment a discussion ends
without implementation, but nothing in `go.md`, `self-improve.md`, or `documentation.md` ever
comes back to ask "is this still blocked, and does anyone still want it?" The `prioritize`
workflow exists to do exactly this triage (Step: "Flag any items that should be DROPPED... or
DEFERRED") but per Proposal 1 it isn't reliably completing, so it isn't closing the loop either.
**Frequency:** 16 tracks meet the pattern; 7 of those are 4+ weeks stale with no revisit logged.
**File:** `workflows/go.md` (orientation path)
**Change:** Add a check analogous to the existing CW-8 auto-closed-session nudge: count tracks in
`tracks/index.md` with status containing "Blocked" whose track file's frontmatter date (or the
index row's opened-date prefix in the filename) is older than N days (suggest 21), and if the
count is >= some threshold (suggest 3), surface a single non-blocking line during `go`'s
orientation: "N tracks have sat Blocked for 3+ weeks — worth a `/shmorch prioritize` pass?" —
mirroring CW-8's "surface once, don't repeat every session" behavior so it doesn't become its own
noise source.
**Improvement:** Gives the deferred-intent stub-track mechanism a matching close-the-loop
mechanism. Right now stub tracks are cheap to open (by design) but nothing makes revisiting them
cheap too, so they accumulate as a growing pile that only gets addressed if the developer happens
to scroll `plan.md`'s Backlog section far enough.

#### Proposal 3: `docs/project/session/` archive directory isn't logged
**Pattern:** The scaffold reverse-check flags `docs/project/session` as an `UNLISTED DIR` — not
in the canonical `EXPECTED_DOCS` list and not recorded in `.shmorch/project_docs_log.md` (which
currently only lists `docs/reference/learning`). It is clearly intentional and actively used —
`session.md`'s own "## History" section links ten files under `session/` as the per-date archive
once entries roll off the live log — not drift or contamination.
**Frequency:** 1 occurrence (structural check, not a session-evidence pattern), but flagged
because the task asked to fold in the structural-check results.
**File:** `.shmorch/project_docs_log.md`
**Change:** Add a line for `docs/project/session` with a short note ("session.md archive, one file
per dated entry, referenced from session.md's History section") so the reverse-check stops
flagging a directory that is working as intended.
**Improvement:** Keeps the scaffold reverse-check's signal-to-noise ratio high — an unlogged but
legitimate directory should be a one-line fix, not a recurring false positive on every
self-improve pass.

### Already addressed

**Repeated `auto-closed by stop hook` entries mid-session.** 7 occurrences in
`docs/project/timelog.md` (2026-07-21 x2, 2026-07-25, 2026-07-26, 2026-08-11, 2026-08-18, plus the
pattern recurring in the `tools/stop.sh` design itself). This is not an open gap: `tools/stop.sh`
deliberately stamps `SESSION_END | auto-closed by stop hook — <branch> @ <last-commit>` whenever
the ledger's last `SESSION_*` line is an unclosed `SESSION_START`, specifically so an abruptly
ended session is still reconstructable from the ledger. The prior self-improve report
`docs/project/self-improve/20260826-shmorch.md` (lines 46-54) confirms `go.md`'s catch-up
mechanism (Steps CW-1 through CW-8) already counts these occurrences and, at 3+, surfaces a
non-blocking "consider whether the wrap trigger itself needs attention" nudge without repeating it
every session — exactly the condition this pattern would otherwise warrant flagging. No new
proposal filed; if CW-8's nudge isn't visibly firing in a live treeclusion session, that is a
verification question, not a doctrine gap.

**Verification-methodology gaps for the heading-fold feature (shipped-then-broken, fold-triangle
direction, single-heading-level test document).** All three defects and their root causes are
already captured as permanent decisions in
`docs/technology/decisions/index.md` ("Verification must use a document with more than one
heading level" and "Heading level cut writes fold state, rather than deriving it at render time"),
with the generalizable lesson explicitly stated (verify against both a multi-level and a
single-level document; check whether an indicator is lying before assuming logic is wrong). This
is resolved doctrine for the project, not a live pattern.

**`linkKind: expand | navigate` field ambiguity.** Resolved in
`docs/technology/decisions/index.md` ("linkKind: hover vs. click, not expand vs. navigate") —
removed as a blocking backlog item 2026-07-28, no data-model change needed. Does not recur in
later plan/backlog entries.

### No-action observations

**Single stray native-setter `dispatchEvent` workaround.** `session.md`'s 2026-08-28 entry notes
forcing `source-mode-select` to `github` via a native-setter `dispatchEvent` because clicking and
keyboard input didn't visibly change the select during verification. Only one occurrence found
across `session.md` and the `session/` archive — keep for next run; propose only if it recurs.

**Single un-stamped `PHASE | prioritize: starting` with no `complete` counterpart in isolation.**
Already rolled into Proposal 1 above as part of a 2-occurrence pattern — not listed separately
here.

**Fat project workflow files:** none found. Every file under `.shmorch/workflows/*.md` (excluding
`README.md`) opens with the required `# Extends:` header — the Extends pattern is being followed
correctly, no action needed.
