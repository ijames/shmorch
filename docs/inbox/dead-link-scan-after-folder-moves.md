# Gap: folder-move backfills don't re-check relative markdown links

Filed from `treeclusion` 2026-08-19.

## Evidence

`tools/backfill-docs-taxonomy.sh`'s MAPPING includes:

```
"docs/product/analytics.md:docs/product/strategy/analytics.md"
```

That `git mv` ran cleanly, but `analytics.md`'s own "In this section" nav line (originally
written by `docs-nav.sh` back when the file lived alongside its siblings) kept bare
same-directory hrefs — `cognitive-architecture.md`, `design/design.md`,
`product-guidelines.md`, `product.md`, `index.md` — none of which still resolve from the
file's new location one directory deeper. Only `../roadmap.md` happened to already carry
a `../` prefix. A sibling file moved into the same new directory
(`web-spec-compliance.md`) carried an identical copy of the same stale nav line.

Running `tools/docs-audit.sh` against this repo just now (2026-08-19) found these two
files' dead links immediately — the detection already exists, it just isn't wired into
the move step, so the staleness sat undetected since whatever backfill run did that git mv.

The same audit run also surfaced 3 pre-existing dead links elsewhere in the repo unrelated
to this specific move (a decisions.md → decisions/ directory split that left two `↔
related` links stale, and a `plan.md` entry naming a track that never existed) — same
class of problem, same fix (`tools/docs-audit.sh` DEAD_LINK), just older drift. Confirms
this isn't a one-off: nothing currently re-runs the audit after either a mechanical
backfill move or hand-edited restructuring, so drift only surfaces when a human notices a
broken link by hand (which is how this was found — reported as "the header fold buttons
are missing on transcluded boxes," which turned out to be unrelated; the actual dead links
were noticed by chance while investigating).

Two smaller false positives also turned up in the same audit run: `docs-audit.sh`'s
DEAD_LINK check strips backtick-code-spans before scanning but not HTML comment blocks, so
template example rows inside `<!-- ... -->` (`sprints/index.md`, `tracks/index.md`) get
flagged even though they're intentionally-unresolvable example syntax, not real links.

## Suggested change

1. **`tools/docs-audit.sh`**: strip `<!-- ... -->` blocks (multi-line, not just
   single-line) alongside the existing backtick-span strip, before the DEAD_LINK grep —
   same rationale as the existing code-span strip ("example syntax inside inline code is
   prose, not a real reference"), just extended to block comments.
2. **`tools/backfill-docs-taxonomy.sh`**: after the mechanical `git mv` loop, run
   `docs-audit.sh`'s DEAD_LINK check (or call it directly) and print any findings as part
   of the script's own report output — so a folder-move backfill surfaces its own
   collateral link damage instead of relying on a human noticing later. Doesn't need to
   auto-fix (target directory for a stale link isn't always inferable — see this repo's
   `plan.md` case, which needed judgment, not a mechanical rename), just needs to surface
   it in the same report the JUDGMENT array already prints.
3. Same wiring point (or `workflows/vacuum.md`) should probably also cover **any** manual
   `git mv`/rename of a docs file, not just the taxonomy backfill script specifically —
   `docs-nav.sh` regen + `docs-audit.sh` DEAD_LINK as a standard post-move pair. Left as a
   judgment call for whoever picks this up on where that's best documented (`vacuum.md`?
   a new "moved a doc file" checklist in `documentation.md`?) since it's process guidance,
   not just a script change.

## Not included here

The actual dead links found in `treeclusion` were fixed directly in that repo (not part of
this proposal — this file is only about the tooling/process gap, not the specific repo's
content).
