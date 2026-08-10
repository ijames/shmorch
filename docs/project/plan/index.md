---
status: Active
updated: 2026-07-24
summary: Docs taxonomy redesign closed and implemented (templates/docs/** restructured); backfill for already-provisioned projects split to its own not-yet-started track. Two other concurrent processes remain — see Current Task.
---

# Shmorch Plan

> **What belongs here:** What to build and in what order.
> Backlog items live as individual files in this directory (one per item, `category`/`status`
> frontmatter) so concurrent work never collides on a shared edit — add a new file, don't
> edit this index. `index.md` only changes for Current Task or Completed updates.
> Changes here do NOT bump VERSION (docs are internal; only skill file changes affect VERSION).

---

## Current Task

None active. The docs cleanup this section used to describe (bringing every track under
`docs/project/tracks/` to clean, frontmatter+backlinks shape) is done: `tools/track-graph-audit.sh`
and `templates/.shmorch/docs/track-template.md` landed 2026-07-21, and the backfill mechanism
track ([`tracks/20260724-dev-docs-taxonomy-backfill`](../tracks/20260724-dev-docs-taxonomy-backfill/index.md))
closed 2026-07-30 — 19 of 20 track `index.md` files now carry frontmatter. The two
"other processes" once tracked here also resolved: messaging-provider design is its own
still-open track ([`tracks/20260721-messaging-provider`](../tracks/20260721-messaging-provider/index.md),
check there for status), and self-improve continues as its own automated process,
logging under its own commits/PRs as before — neither needs tracking here.

---

---

## Completed

<!-- Items closed here when the skill change is merged to main. -->

- [x] **Docs taxonomy redesign** — new top-level `docs/` skeleton (`product/`, `technology/`, `reference/`, `project/`, `inbox/`) replacing `architecture/development/product/reference/state/to_review`; resolved the architecture-vs-reference content-type conflict (technology/architecture/ = narrative, reference/ = lookup-only), split decisions into `product/decisions/` + `technology/decisions/` only, scoped Diataxis narrowly inside `reference/instructions/`. Implemented in `templates/docs/**`, `core/documentation.md`, `shmorch-core.md`, `templates/.shmorch/docs/track-template.md`. Backfill for already-provisioned projects split to its own track (see Backlog). [`docs/project/tracks/20260724-docs-taxonomy-redesign`](../tracks/20260724-docs-taxonomy-redesign/index.md). Closed 2026-07-24.

- [x] **Wrap-friction fixes (self-improve)** — `go.md` escalates when 3+ sessions in a row end without a real wrap; `build.md` syncs track `index.md` Status before opening the PR; `self-improve.md` cross-checks `decisions.md`/`AGENTS.md` before re-proposing an already-resolved pattern; `vacuum.md` gained an untracked-file scan escalating to a backlog item after 2+ passes. PR #58 merged 2026-07-18.

- [x] **Bounded timelog/session reads** — `orient.md`, `wrap.md`, `self-improve.md` no longer `Read` `session.md`/`timelog.md` whole; bounded to current/most-recent entries via `tail`/`awk`. PR #57 merged 2026-07-18.

- [x] **Merge policy: regular merge, not squash** — disabled squash and rebase merge on the GitHub repo (`gh repo edit --enable-squash-merge=false --enable-rebase-merge=false`), leaving only merge commits allowed. Enforced at the platform level — no doc or runtime check needed. 2026-06-19.

- [x] **Multi-CLI portability (omp / Pi / Codex / Gemini / opencode / Cursor / Antigravity)** — P0 + P1 + P2 all done: AGENTS.md-first context chain with per-CLI root files (AGENTS/CLAUDE/GEMINI) + plain-text bootstrap for literal-`@` CLIs; `$SHMORCH_HOME` indirection (recipe in `core/portability.md`, resolved at session start, stamped into `.shmorch/home`, 117 path refs codemod'd); CLI-neutral subagent protocol, dispatch, launchers, and omp TS safety hook; `/shmorch sync` migrates existing repos; README stale Claude-only spots fixed; scheduler doc scoped as Claude-only. `docs/state/tracks/20260707-multi-cli-portability/index.md`. Closed 2026-07-17.

- [x] **Entry-point consolidation** — `go` as the single dispatcher (provision → orient); Phase 2 context trim (`core/operations.md` carve-out, front-matter previews on `docs/state/*.md`, `docs/state/index.md` skeleton index, `orient.md` Step 0 pulse check). Phase 3 (store shape) split to `tracks/20260717-state-store-shape/`. `docs/state/tracks/20260707-entrypoint-consolidation/index.md`. Closed 2026-07-17.

- [x] **Docs solidification: continuous placement + version-triggered backfill** — `vacuumer` role gained a "docs placement" hunt category backed by an optional `PostToolUse` hook (`templates/.claude/hooks/post-tool-docs.sh`) that fires right after each docs write/edit; opt-in via `.shmorch/AGENTS.md`. `core/documentation.md` gained an Architecture Changelog (`Compat: additive | backfill`); `auto-update.md` Step 2.8 offers scoped, per-entry, opt-in backfill using the existing `VERSION` date as the comparison axis — no new semver. Standalone `solidify` command dropped after feedback split the problem into these two concerns. `docs/state/tracks/20260717-docs-solidification-framework/index.md`. PR #55 merged 2026-07-17.
