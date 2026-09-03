# Templates carry non-generic, leftover content from other projects

**Filed from:** Paths, 2026-08-29

## Observation

During an `auto-update` legacy-taxonomy backfill on Paths (an Electron browser project),
`docs/README.md` turned out to contain content entirely unrelated to Paths — PHP hosting
config, `[trading]` / `[services.schwab.api]` sections, a Schwab trading API reference.
None of that is Paths content. It reads as boilerplate copied from a different project's
docs scaffold at some point and never genericized or cleaned up.

The user noted this is "happening repeatedly" — implying this isn't the first time a
project's scaffolded/templated docs turned out to carry stale content that clearly belongs
to a different project.

## Proposed fixes

1. **Audit `templates/.shmorch/` and `templates/docs/` (or wherever `docs/README.md`'s
   source template lives) for any content that isn't fully generic** — placeholder text,
   `{{Project Name}}`-style tokens, or structural scaffolding only. No concrete
   product/API/tech-stack references should ever ship in a template.
2. **Add a detection heuristic**, either as a doc or a check `init`/`auto-update` runs:
   when scaffolded content contains proper nouns, API/vendor names, or domain terms that
   don't match anything in the current project's `context.md`/`stack.md`, flag it as a
   likely bad copy rather than silently trusting it as legitimate project content. This
   should apply to any docs file discovered during `go`/`auto-update`, not just freshly
   scaffolded ones — old projects can carry this same contamination from an earlier,
   less careful init.

## Not yet done

Paths' own `docs/README.md` was deleted (superseded by `docs/index.md`, the real
canonical index) as part of the same session — that's the project-level fix. This item is
about preventing recurrence at the template/skill level.
