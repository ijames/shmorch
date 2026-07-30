---
status: Closed
updated: 2026-07-30
summary: Built tools/docs-audit.sh (dead links, frontmatter placement, parent-link presence, index linkage, one-way ↔ related, line-overlap duplicates) and wired it into documentarian.md Step 2 alongside track-graph-audit.sh.
---

↑ [Shmorch Plan](../../plan.md)
→ `tools/docs-audit.sh` (new) + `workflows/documentarian.md` § Step 2 (Orient)

# Track: Docs-audit tool

**Status:** Closed
**Opened:** 2026-07-30
**Domain:** Documentation architecture

## Why

Discussion while reviewing Treeclusion's migrated docs tree (see
`tracks/20260724-dev-docs-taxonomy-backfill`) surfaced a broader problem: nothing
mechanically checks a docs tree for dead links, missing front-matter, orphaned files,
one-way cross-references, or redundant content. `track-graph-audit.sh` already covers
this for `docs/{project,state}/tracks/`; the rest of the tree had no equivalent.

Scoped deliberately to what's actually deterministic — link resolution, front-matter
placement (a rule already defined in `core/documentation.md`), `↑`/`↔` presence and
reciprocity, and line-overlap duplicate detection. Folder-vs-subject-matter drift and
true tag-completeness are semantic judgment calls, not mechanical checks, and shmorch's
front-matter schema has no `tags:` field to check completeness of in the first place —
building a fake check for either would cost more triage confusion than it'd save. That
boundary is where RAG-style retrieval might eventually earn its complexity, but not at
shmorch/Treeclusion's current scale (low hundreds of files, single-repo scope).

## What changed

- **`tools/docs-audit.sh`** — pure-detection script, same conventions as
  `track-graph-audit.sh` (machine-parseable output lines, `ponytail:`-style comments on
  deliberate heuristic ceilings). Checks: `DEAD_LINK`, `MISSING_FRONTMATTER`,
  `MISSING_PARENT_LINK`, `UNLINKED_FROM_INDEX`, `ONE_WAY_RELATED`, `DUPLICATE_CONTENT`.
- **Wired into `workflows/documentarian.md` Step 2 (Orient)**, run alongside
  `track-graph-audit.sh` — same "scan mechanically, triage with judgment" split; Step 2
  now also notes that `docs-audit.sh` findings are candidates, not verdicts.

## Work log

### 2026-07-30

Wrote `tools/docs-audit.sh`. Two bugs found and fixed while testing against shmorch's own
(still unmigrated) `docs/` tree:

- Inline code spans showing link syntax as a literal example (`` `[text](path.md#anchor)` ``)
  were mis-parsed as real dead links. Fixed by stripping backtick-delimited spans (`sed -E
  's/`[^`]*`//g'`) before link extraction.
- Under `set -euo pipefail`, a bare `... | while read x; do ... done` pipeline aborts the
  whole script the instant a file has zero matches (a normal case, not an error) — `grep`
  exits 1 on no-match, `pipefail` propagates it, `set -e` treats the unguarded pipeline as
  fatal. Fixed by appending `|| true` after the closing `done` on both affected blocks
  (`DEAD_LINK`, `ONE_WAY_RELATED`).

Verified clean run (`exit 0`) against shmorch's own tree — real findings surfaced (four
dead links from pre-taxonomy-migration paths, two missing-frontmatter files, five
missing-parent-link files, five duplicate-content pairs at 42-63% overlap) confirming the
script actually detects the conditions it claims to, not just that it runs without error.
Closing this track as design-and-implementation complete; the surfaced findings themselves
are shmorch's own dogfood-migration cleanup, tracked separately, not this track's scope.
