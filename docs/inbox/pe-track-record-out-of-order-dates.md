# pe-synthesizer: track-record "later session" instruction assumes arrival order, not session date

Filed from `shming.com`, 2026-09-05.

## Gap

`agents/roles/pe-synthesizer.md` § Task, the `{#track-record}` paragraph, says:

> Reinforces/Adds/Conflicts still apply (e.g. a later session reporting a project
> shipped is an update to an earlier "in progress" entry, not a duplicate)

"Later" here reads as "processed later in this batch," not "has a later session
date." The workflow's own design assumes sessions are worked oldest-first
(`tools/scan.py` prints backlog "oldest first," and Step 2 of
`workflows/personal-eval.md` treats N-from-the-top as the normal path) — but nothing
stops a user from deliberately pulling sessions out of chronological order (e.g. to
get span across projects/time rather than a dense contiguous run), and nothing in the
synthesizer role tells it to guard against that when updating `track-record.md`.

Concretely: if a session dated 2026-08-01 ("shipped X") is processed in one batch,
then a session dated 2026-07-10 ("X in progress") is processed in a later batch, the
synthesizer — going only on "existing bullet = past, new evidence = present" — could
plausibly treat the July session as the newer update and downgrade the entry's status
backwards, since it's never told to compare the *session's own date* (in the summary
header) against the *existing entry's cited date* (in its footnote) rather than
processing order.

This doesn't affect the trait sections (work-styles, values, etc.) — those never
overwrite, they only add footnotes or `(tension: ...)` notes next to what's already
there, so out-of-order processing is safe there by construction. It's specific to
`track-record.md`'s literal "update the status" behavior.

## Suggested shmorch-side change

`agents/roles/pe-synthesizer.md`, the `{#track-record}` paragraph — replace the
implicit "later session" phrasing with an explicit date comparison:

> Before treating new evidence as superseding an existing track-record entry, compare
> the *new session's own date* (from its summary header) against the *existing
> entry's* cited session date(s) — not which one you're processing first. Only update
> an entry's status/outcome when the new evidence's session date is actually later.
> If the new evidence's date is earlier than an entry already reflecting a more
> advanced status, add it as historical context on that entry (or its own dated note)
> rather than reverting the status.

Low-stakes, doc-only — a `PATCH` version bump per `core/operations.md`.
