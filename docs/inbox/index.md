# Inbox

Drop files here — captured observations, friction points, proposals — and `self-improve`
will pick them up to evaluate and either apply, defer, or discard.

↑ [docs/](../README.md)

---

Items here are not authoritative. They graduate into `workflows/`, `core/`, `agents/`,
`tools/`, or a track once reviewed and accepted, or are removed once resolved.

**Open:**

- [markdown-no-hard-wrapping.md](markdown-no-hard-wrapping.md) — filed from `treeclusion` 2026-08-20. Shmorch has no stated position on hard-wrapping markdown, so every skill file and template is wrapped at ~95 columns and every agent inherits the convention by imitation. Proposal: authored markdown is source for a renderer, not a reading surface — continuous prose stays continuous. Includes the second-order evidence that hard wrapping manufactured a parser bug class in `treeclusion`, and the boundary that parsers must stay tolerant of hard-wrapped input they do not control. Lands in `core/documentation.md` plus `templates/`.
- [dead-link-scan-after-folder-moves.md](dead-link-scan-after-folder-moves.md) — filed from `treeclusion` 2026-08-19. `backfill-docs-taxonomy.sh`'s mechanical `git mv`s never repair relative links after a folder move; wire `docs-audit.sh`'s DEAD_LINK check into its report step and strip HTML comments. Blocks a wanted multi-repo link sweep.
- [wrap-step84-blocked-by-own-precommit-hook.md](wrap-step84-blocked-by-own-precommit-hook.md) — filed from `treeclusion` 2026-08-20. `workflows/wrap.md` Step 8.4 mandates editing `.shmorch/AGENTS.md` inline, but `templates/.githooks/pre-commit` blocks committing anything outside `docs/project/` directly to `main` — so every wrap on `main` ends with a dirty tree while `commit-session-state.sh` reports success.

(previously resolved: `learning-log-external-reference-reconsider.md` and
`pre-commit-template-stale-taxonomy.md`, both filed from `treeclusion` 2026-08-18 —
learning-log dual-write adopted in `shmorch-core.md`/`workflows/learn.md`;
`templates/.githooks/pre-commit` updated to the current docs taxonomy, 2026-08-18.
`session-md-growth-split-rule.md`, also filed from `treeclusion` 2026-08-18 — growth
rule added to `core/documentation.md`, checks wired into `workflows/wrap.md`, 2026-08-18)
