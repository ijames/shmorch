---
loads_when: user-directed knowledge capture, or (no args, in $SHMORCH_HOME) learning-corpus health check
size: 55 lines
---

# Workflow: learn

## Concept file schema

```yaml
---
title: <Concept Name>
domain: <one of: infra | frontend | backend | data | testing | security | product-growth | tooling | agents | docs | process>
stack: [<specific tool/tech proper nouns, e.g. git, vercel, react — empty [] if none>]
kind: <one of: pattern | gotcha | terminology | tool-usage | decision>
created: YYYY-MM-DD
---
```

Genuinely project-specific knowledge: `docs/reference/learning/<slug>.md` only (flat, no
subfolders — too small a corpus per project to need them). General-purpose knowledge (true
on any project) is captured in *both* places:
- `docs/reference/learning/<slug>.md` — as it actually came up here, project context intact
- `~/.shmorch/learning/<domain>/<slug>.md` — a polished, project-agnostic rewrite for the
  global knowledge graph (domain subfolder matches the frontmatter's `domain` value)

The two copies are independent, not a sync pair — the local one can stay specific to this
repo's story, the global one doesn't reference back to it. No backreference field needed.

Faceted, not a flat `tags:` list — `domain`/`stack`/`kind` are independent dimensions so
entries can be filtered by any combination (e.g. `domain:infra AND kind:gotcha`) without a
folder hierarchy. `domain` and `kind` are closed vocabularies (add a new value only when an
entry genuinely doesn't fit any existing one, and note the addition here); `stack` is
free-form.

---

## With args — capture

1. Ask, if not obvious from what the developer said: general-purpose (local + global) or
   specific to this project (local only)? Default to general-purpose — most captured
   concepts are.
   **Bulk/backfill migrations (multiple files, multiple repos) are not exempt from this
   question** — classify scope per file and confirm with the developer before writing
   anything, even under time or parallelism pressure. A prior narrowing of scope for one
   part of a request (e.g. the command's own automatic behavior) never silently overrides
   the destination for a separately-requested action.
2. Write `docs/reference/learning/<slug>.md` (kebab-case title) with the frontmatter
   above, body: what it is, why it exists, where it came up here.
3. General-purpose only — also write a polished, project-agnostic version of the same
   concept to `~/.shmorch/learning/<domain>/<slug>.md` (create `<domain>/` if it doesn't
   exist yet). Strip the project-specific "where it came up" detail; keep the concept
   itself. This copy is independent of the local one — no backreference field, no
   requirement to keep them in sync after the fact.
4. Global captures only — append a one-line entry to `~/.shmorch/learning/index.md`
   (create it, with a `## Facets` section documenting the schema above, if it doesn't
   exist yet):
   ```
   - [<title>](<domain>/<slug>.md) — `<domain>` / `<kind>`
   ```

---

## No args, in `$SHMORCH_HOME` — audit

For each learning file (`~/.shmorch/learning/**/*.md`, `docs/reference/learning/*.md` or
legacy `docs/reference/learning.md`), read only what's needed to judge — frontmatter plus
a skim, not a full careful read of every entry:

- **Size:** file (or, for a multi-entry legacy file, any single entry) over ~150 lines —
  flag as a split candidate.
- **Shape:** frontmatter present and matches the schema above; file sits under the
  subfolder matching its own `domain` value; global `index.md` has a line for every
  global file (no orphans).
- **Meaning:** titles/tags that look like near-duplicates of each other — surface for the
  developer to merge or distinguish, don't merge automatically.

Report as a short list, findings only — this is a lint, not a gate; no action is forced.
