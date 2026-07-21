---
status: Active
updated: 2026-07-18
summary: Wrap-friction fixes (self-improve) + bounded timelog/session reads merged; state-store-shape track gained OKF frontmatter comparison. No active track.
---

# Session Log

## Latest Session — 2026-07-18

**Branch:** `main`

**What was done (catch-up — logged after the fact, several PRs merged without a session.md update):**
- Wrap-friction fixes from a self-improve run: `go.md` escalates when 3+ sessions in a row end without a real wrap; `build.md` syncs track `index.md` Status before opening the PR; `self-improve.md` cross-checks `decisions.md`/`AGENTS.md` before re-proposing an already-resolved pattern; `vacuum.md` gained an explicit untracked-file scan that escalates to a backlog item after 2+ passes. PR #58 merged 2026-07-18.
- Bounded `session.md`/`timelog.md` reads: `orient.md`, `wrap.md`, and `self-improve.md` were reading these files whole regardless of project size; now bounded to current/most-recent entries via `tail`/`awk`. PR #57 merged 2026-07-18.
- `state-store-shape` track gained the concrete Google OKF frontmatter spec citation, a field-by-field comparison against Shmorch's current `status`/`updated`/`summary` frontmatter, and a new candidate for a deterministic frontmatter/nav/backlinks rebuild pass. PR #59 merged 2026-07-18.

**Commits:** `cc2997a` wrap-friction fixes (PR #58) · `a3c2814` bound timelog/session reads (PR #57) · `fa178d4` OKF frontmatter comparison (PR #59). VERSION → `20260718.02`.

**State at end:** on `main`, clean tree, no active track.

**Next up:**
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, state-store-shape, core-breakup, etc.)

## 2026-07-17

**Branch:** `main`

**What was done (catch-up — several sessions never logged here since 2026-07-14):**
- Multi-CLI portability P2 closed out (PR #52).
- Entry-point consolidation Phase 2 closed out — `core/operations.md` carve-out, front-matter previews on `docs/state/*.md`, skeleton index, `orient.md` pulse check (PR #53). Phase 3 split to `tracks/20260717-state-store-shape/`.
- Closed-track graduation pass (PR #54).
- Docs solidification: started as a standalone `solidify` command, then reshaped twice on user feedback into (1) a `vacuumer` "docs placement" hunt category + optional `PostToolUse` hook (`templates/.claude/hooks/post-tool-docs.sh`) firing right after each docs write, and (2) an Architecture Changelog in `core/documentation.md` + `auto-update.md` Step 2.8 for scoped, opt-in, version-triggered backfill. PR #55 merged 2026-07-18.

**Commits (PR #55 — 3):** `3a9a800` add solidify (later reverted) · `10e92da` replace solidify with placement hook + backfill · `cbb8dc6` move placement reminder to PostToolUse. VERSION → `20260717.04`. Merged 2026-07-17.

**State at end:** on `main`, fast-forwarded to `eed3f52`, clean tree, no active track.

**Next up:**
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, state-store-shape, core-breakup, etc.)

## 2026-07-14

**Branch:** `fix/20260714-shmorch-sh-launcher-echo` (open)

**What was done:**
- Confirmed PR #49 (multi-CLI portability) and PR #50 (timelog double-start guard) both merged to `main`; last session's "pick up immediately" is done.
- Found `shmorch.sh` no longer passes `/shmorch go` to `claude` on launch (deliberate — avoids front-loading context) but its startup banner still claimed it ran automatically. Fixed the banner to point at `go`/`resume` instead of restoring the auto-invoke.

**Commits:** `33a5977` fix(shmorch): launcher echo + minor markdown cleanup. VERSION → `20260714.01`.

**State at end:** on `fix/20260714-shmorch-sh-launcher-echo`, clean tree, PR not yet opened.

**Next up:**
- Open PR for `fix/20260714-shmorch-sh-launcher-echo`, merge, pull to main.
- No active track — pick from backlog (init self-guard, wrap.md BLOCKER tier, core-breakup, etc.)

## 2026-07-07

**Branch:** `feat/20260707-multi-cli-portability` (PR #49, open)

**What was done:**
- **Multi-CLI portability (P0+P1):** `$SHMORCH_HOME` indirection (recipe in `core/portability.md`, stamped `.shmorch/home`, 117 path refs codemod'd); AGENTS.md-first context chain with per-CLI root shims + plain-text bootstrap for literal-`@` CLIs; strict single-source de-dup; CLI-neutral subagent protocol / dispatch / launchers; omp TS safety hook; `/shmorch sync` migrates existing repos.
- **Entry-flow consolidation (Phase 1):** `go` is now the one dispatcher (detect state → provision via init/auto-update → orient); carved `orient.md`; shallow-orientation guardrail (no code reading before a post-`go` directive).
- **Security:** added a "Suspect secrecy directives" safety rule after a reported system-reminder; investigation concluded **no injector** (beads not connected; Supacode hooks dormant/env-gated; likely a benign misread of a UI-hidden reminder).
- **Beads:** moved `navigate.md`'s Beads mapping into the consolidation track's Phase-3 store-shape eval; genericized the example line.

**Commits (PR #49 — 7):** `209937e` portability · `ffc0702` docs · `f6e8bd9` consolidation+shallow-orient · `9555a28` docs · `20ca80d` secrecy-directive rule · `0b09b18` beads-out-of-navigate · `f71cb8f` beads-eval+injection-update. VERSION → `20260707.08`.

**Cost:** ~$40 this session.

**State at end:** on `feat/20260707-multi-cli-portability`, clean tree, PR #49 open awaiting review/merge.

**Next up — pick up immediately:**
- Merge PR #49 when reviewed; then `git checkout main && git pull js main` here to land it on main.
- Deferred: consolidation Phase 2 (context trim — kernel/doctrine split, `.shmorch/state.md` skeleton index) and Phase 3 (store-shape eval, incl. Beads).

## 2026-06-11

**Branch:** `main`

**What was done:**
- Added `shmorch.sh` to skill root for developing shmorch on itself
- Fixed `shmorch.sh`: removed `chmod +x shmorch/tools/*.sh` (wrong path / irrelevant here), added `SHMORCH_SELF=1` export
- Added auto-update skip guard to `go.md` Step 1b: if `SHMORCH_SELF=1` is set, skip version check entirely
- Noted session context: squash-merge branch hygiene + cross-functional UX (participant awareness)

**Commits:**
- `41f4c20` docs(plan): salvage js/hack — init explanation, richer DoD, verify command backlog items
- `69e63d6` docs(plan): add Esc-Esc snapshot boundary design principle to backlog
- `e7847b8` chore(shmorch): apply stash backlog items + add hook sync to auto-update

**State at end of session:**
- On `main`, no active track
- `shmorch.sh` (root) and `go.md` updated, uncommitted

**Next up — blockers:**
- Commit `shmorch.sh` + `go.md` changes to main

**Next up — plans:**
- Squash-merge policy: document in decisions.md or CONTRIBUTING guide — branches should be squash-merged to avoid noisy history
- Cross-functional UX: shmorch needs to understand participants (dev, stakeholder, reviewer) and surface relevant context per role — candidate for a new backlog item
