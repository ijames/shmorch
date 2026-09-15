---
title: Inbox directories are triage-only, not an archive
domain: process
stack: []
kind: pattern
created: 2026-09-14
---

`docs/inbox/` in this repo is a drop zone, not a destination
(`workflows/check-inbox.md`). Once an item's content is folded into its
real home (`core/`, `workflows/`, `agents/`, a plan, or a track), the
inbox file itself is removed — not left in place with a `## Resolution`
section appended. There's no "resolved, kept for the record" state —
only Open (still needs triage) or Deferred (status-stamped, left in
place until a named trigger).

**Where it came up here:** this repo's own `docs/inbox/` had drifted from
its documented process — several already-resolved items (e.g.
`expand-migrate-contract-reversible-data-migrations.md`,
`git-discipline-self-repo-direct-to-main-drift.md`) were sitting in the
folder with Resolution notes rather than being removed. An agent working
the inbox inferred "leave resolved items in place" as the established
convention from observing that pattern, and stated it as fact — the
developer corrected this directly, and re-reading `workflows/check-inbox.md`
Step 3 confirmed the documented process already said to remove the file.
Fixed via PRs #143 and #144 (removed the two drifted files, trimmed
`docs/inbox/index.md`'s references to them).

The lesson generalizes beyond this repo — see the global copy at
`~/.shmorch/learning/process/inbox-is-triage-only.md` — but the specific
failure mode worth remembering here is: don't infer a folder's intended
convention from what's currently sitting in it. The folder itself can be
the thing that's drifted from its own documented process.
