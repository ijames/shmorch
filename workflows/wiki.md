---
loads_when: auditing the learning log — promote recurring concepts, check frontmatter divergence from llm-wiki
size: 70 lines
---

# Workflow: wiki

Two passes over the learning log, both frontmatter-only — never reads a concept file's body.

## Concept file schema

```yaml
---
title: <Concept Name>
tags: [tag1, tag2]
scope: global | project
seen_in: [project-a, project-b]   # global entries only
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Global: `~/.shmorch/learning/<slug>.md` (+ `index.md` catalog, `log.md` append-only ingest
log). Project: `docs/reference/learning/<slug>.md`. Legacy single-file
`docs/reference/learning.md` (pre-dating this schema) is left as-is — no forced migration.

---

## Step 1 — Bootstrap global store if missing

```bash
mkdir -p ~/.shmorch/learning
[ -f ~/.shmorch/learning/index.md ] || printf '# Learning index\n\nCatalog of globally-captured concepts, one line each.\n' > ~/.shmorch/learning/index.md
[ -f ~/.shmorch/learning/log.md ] || printf '# Learning log\n\nAppend-only ingest record.\n' > ~/.shmorch/learning/log.md
```

## Step 2 — Placement pass (frontmatter only)

```bash
for f in docs/reference/learning/*.md ~/.shmorch/learning/*.md; do
  [ -f "$f" ] || continue
  [[ "$(basename "$f")" == "index.md" ]] && continue
  awk '/^---$/{n++; next} n==1' "$f"
done
```

Read each file's frontmatter block (not the body). For every **project-local** entry
(`scope: project`), check whether an equivalent title/tags already exists in
`~/.shmorch/learning/`. If it does, or if a `seen_in` list would grow to 2+ projects,
propose promotion: move the file to `~/.shmorch/learning/<slug>.md`, set `scope: global`,
append the current project to `seen_in`, add a one-line entry to `~/.shmorch/learning/index.md`,
append a line to `log.md` (`## [YYYY-MM-DD] promote | <title> — from <project>`), and replace
the project file with a one-line pointer. Present each proposed promotion to the developer
before acting — same act-now-or-defer shape as `check-inbox`.

## Step 3 — Divergence check vs. llm-wiki

llm-wiki reference: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
(three layers — sources / wiki / schema doc; operations — Ingest / Query / Lint;
`index.md` as content catalog; `log.md` as chronological ingest record; optional
per-page YAML frontmatter for tags/dates/source-counts).

Report a short checklist, adopted vs. missing:
- `index.md` present and per-entry (not just filenames) — catalog entries need a one-line
  summary alongside the link, not just a bare list
- `log.md` present and append-only with parseable `## [date] verb | title` entries
- Every concept file has the frontmatter block above (flag any without one)
- Orphans: concept files with no `index.md` line pointing at them
- Cross-references: concept files that mention another concept by name but carry no link
  to it (best-effort grep, not exhaustive)

Present the checklist to the developer. This is a report, not a gate — no action is forced.

## Step 4 — Stamp

```bash
bash "$SHMORCH_HOME/tools/timelog.sh" "PHASE" "wiki: audit complete"
```
