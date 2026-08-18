---
loads_when: user-directed knowledge capture, or (no args, in $SHMORCH_HOME) learning-corpus health check
size: 55 lines
---

# Workflow: learn

## Concept file schema

```yaml
---
title: <Concept Name>
tags: [tag1, tag2]
created: YYYY-MM-DD
---
```

Location IS the scope — no redundant `scope:` field. General-purpose knowledge:
`~/.shmorch/learning/<slug>.md`. Genuinely project-specific: `docs/reference/learning/<slug>.md`.

---

## With args — capture

1. Ask, if not obvious from what the developer said: general-purpose (global) or specific
   to this project? Default to global — most captured concepts are.
2. Write `<slug>.md` (kebab-case title) to the right location with the frontmatter above,
   body: what it is, why it exists, where it came up.
3. Global captures only — append a one-line entry to `~/.shmorch/learning/index.md`
   (create it, one line per file, if it doesn't exist yet):
   ```
   - [<title>](<slug>.md) — <one-line summary>
   ```

---

## No args, in `$SHMORCH_HOME` — audit

For each learning file (`~/.shmorch/learning/*.md`, `docs/reference/learning/*.md` or
legacy `docs/reference/learning.md`), read only what's needed to judge — frontmatter plus
a skim, not a full careful read of every entry:

- **Size:** file (or, for a multi-entry legacy file, any single entry) over ~150 lines —
  flag as a split candidate.
- **Shape:** frontmatter present and matches the schema above; global `index.md` has a
  line for every global file (no orphans).
- **Meaning:** titles/tags that look like near-duplicates of each other — surface for the
  developer to merge or distinguish, don't merge automatically.

Report as a short list, findings only — this is a lint, not a gate; no action is forced.
