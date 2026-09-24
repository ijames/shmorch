# Investigate closing tracks automatically on merge (optional)

**Status:** Deferred 2026-09-23 — revisit if `tracks/index.md` drifts again despite `touch` now reconciling it from track frontmatter on every `resume`/`wrap` (PR #149). The part still open is enforcing it at merge time (a hook or `merge-chain.sh` step).

**Filed from `darkbadge` 2026-09-16.**

## What happened

A `/shmorch prioritize` run plus a manual reconciliation against
`docs/project/tracks/index.md` found 15 merged tracks in DarkBadge with no row
at all in the master table (`20260703-nav-transitions`,
`20260809-ideas-tile-thumbnails`, `20260811-sqs-dlq-backoff`,
`20260818-news-article-full-page`, `20260818-universal-item-thumbnails`,
`20260819-explore-hub-drop-library-section`, `20260831-worker-job-failure-alerting`,
`20260901-dedupe-append-only-scores`, `20260908-admin-nav-news-library-explore`,
plus 4 more Open-table rows that were stale in the other direction — merged
weeks ago but still listed Open). Fixed by hand in that session.

## The gap

`build.md`'s pre-PR checklist says "update the track's `index.md` Status
field" — read (correctly, but insufficiently) as the track's own file, not
the separate master-table row. `git-discipline.md`'s mandatory "After any PR
merge" sequence (`checkout main && pull`) never mentioned the master table at
all. So the row only gets closed if someone remembers to do it as a distinct
step, or `touch`/`wrap`/documentarian happens to run and catch the drift —
none of which are guaranteed to run every merge. A follow-up edit added an
explicit line to `git-discipline.md`'s post-merge sequence requiring the
master-table row move as part of the merge itself, but that's a doctrine
change, not automation — it still depends on the step being followed by
hand each time.

## Not resolved — needs a decision

- Is a doctrine reminder enough, or does this need actual mechanical
  enforcement (e.g. a `tools/merge-chain.sh` step, or a git hook keyed off
  `gh pr merge`, that greps the merged branch's track slug and fails/warns if
  `tracks/index.md` wasn't touched in the same commit range)?
- Should this be opt-in per project (a flag in `.shmorch/AGENTS.md`) given
  it'd need to parse the branch name back to a track slug — is that mapping
  reliable enough across projects to automate, or too project-specific for a
  Shmorch-wide default?
- Related and possibly should be resolved together: the master table itself
  duplicates status already recorded in each track's own frontmatter. Worth
  asking whether the master table should be generated (a script that walks
  `docs/project/tracks/*/index.md` frontmatter and renders the table) rather
  than hand-maintained twice — see also the companion question in
  [plan-item-graduation-undefined](plan-item-graduation-undefined.md) about
  whether track and plan files should be this long-lived in the first place
  (`track-info-retention-vs-graduation.md` was resolved and removed 2026-09-16).
