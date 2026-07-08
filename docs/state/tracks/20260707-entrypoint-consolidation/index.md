↑ [Shmorch Plan](../../plan.md)
→ [workflows/go.md](../../../../workflows/go.md) · [workflows/orient.md](../../../../workflows/orient.md) · [shmorch-core.md](../../../../shmorch-core.md)

# Track: Entry-point consolidation — go as the one door

**Status:** Active (Phase 1 landed)
**Started:** 2026-07-07
**Domain:** Entry flow / context management

## Why

Running `./shmorch.sh` (or opening any CLI in a repo) has ~six intents — investigate
read-only, create a new project, add shmorch to an existing repo, full `go`, `resume`,
or "it's the skill's own repo." Previously the user (and the SessionStart prompt) had to
pick between `init` / `go` / `resume`, and `go` assumed the repo was already provisioned.
Shmorch is context-heavy, so every extra always-loaded command doc and every eagerly-read
workflow costs budget. Collapsing to **one entry that detects state and lazily loads only
the phase that fires** cuts both the decision burden and the context load.

## Decision

**`go` is the single entry dispatcher; `init` and `auto-update` become the provisioning
engines it routes to by state.** "go decides about auto-update, which if never done is
just init" — init is auto-update from an empty starting state.

Chose an **orchestration dispatcher that lazily loads the fresh/migrate/orient phases**
over physically concatenating `init.md` + `auto-update.md` into one `provision.md`.
Rationale: the file-merge doesn't reduce context (same bytes) and risks transcribing two
~300-line engines; **lazy loading** is what actually cuts budget, and the dispatcher
delivers the same intent with far less risk on a live branch. `init`/`sync`/`resume`
remain directly invokable.

## State matrix (what `go` decides)

| State | Detected by | Runs |
|---|---|---|
| SELF | `$SHMORCH_SELF` / cwd == `$SHMORCH_HOME` | orient only |
| UNINITIALIZED | no `.shmorch/AGENTS.md` + no `context.md` | provision-fresh (init) → orient |
| BEHIND | `.shmorch/VERSION` < skill | offer update → auto-update → orient |
| CURRENT | versions equal | orient |
| RESUMABLE (overlay) | `check-session-state.sh` INTERRUPTED / pick-up note | offer resume vs go |

## Phase 1 — landed (this track)

- `workflows/go.md` rewritten as the **dispatcher**: Step 0 resolve `$SHMORCH_HOME` →
  Step 1 detect state (+ resumable overlay) → Step 2 provision (2a init / 2b auto-update)
  → Step 3 session-start + catch-up wrap → Step 4 run orient.
- `workflows/orient.md` **new** — the orientation phase carved from old `go.md`
  (context/stack, session, plan, leftover-work, test-failure + memory-staleness checks,
  gaps + propose), renumbered 1–7, plus the working-session references. Identity/safety/
  timing are not duplicated — they load from `shmorch-core.md`.
- `init.md` / `auto-update.md` kept as the provisioning engines, tagged as `go` phases
  (still `/shmorch init` / `/shmorch sync`).
- `shmorch-core.md` session-start no longer stops uninitialized repos with "run init" — it
  routes everything through `go`, which provisions as needed.

## Deferred

- **Phase 2 — context trim:** split `shmorch-core.md` into a tiny always-on kernel +
  on-demand doctrine; add a ~10-line `.shmorch/state.md` skeleton index so `orient` reads a
  summary before pulling whole state files.
- **Phase 3 — store shape:** evaluate a graph/wiki backend for state (tracks/decisions)
  so `go` pulls the current-focus subgraph, not whole files. Prior art:
  `tracks/20260525-graph-first-docs`, `tracks/20260609-state-file-discipline`,
  `tracks/20260608-cross-project-knowledge`. Do only after measuring Phase 1/2 gains.
- Optional: physically merge the two engines into one `provision.md` (low value; only if
  a single file proves clearly simpler in practice).

## Work log

### 2026-07-07

- Carved `orient.md`; rewrote `go.md` as the state dispatcher; routed UNINITIALIZED→init,
  BEHIND→auto-update, added resumable overlay; updated `shmorch-core.md` session-start;
  tagged the engines. Verified state routing by trace + no dangling step refs. VERSION → 20260707.04.
- Added the **shallow-orientation guardrail**: `orient` reads only `docs/state/*` + git metadata; no reading/grepping/analyzing source code (or spawning discovery) until the user gives a directive after `go`. Carved the same exception into `shmorch-core.md`'s "Always keep moving" line (the root cause). VERSION → 20260707.05.
