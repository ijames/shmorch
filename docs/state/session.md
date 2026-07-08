# Session Log

## Latest Session — 2026-07-07

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
