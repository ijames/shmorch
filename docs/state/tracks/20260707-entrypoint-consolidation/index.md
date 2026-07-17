↑ [Shmorch Plan](../../plan.md)
→ [workflows/go.md](../../../../workflows/go.md) · [workflows/orient.md](../../../../workflows/orient.md) · [shmorch-core.md](../../../../shmorch-core.md)

# Track: Entry-point consolidation — go as the one door

**Status:** Closed (Phase 1 + 2 landed; Phase 3 split to `tracks/20260717-state-store-shape`)
**Started:** 2026-07-07
**Closed:** 2026-07-17
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

## Phase 2 — landed (this track)

- `core/operations.md` **new** — Timing, Communication Notifications, Vacuum Protocol,
  Checkpoints, Version + skill-change-workflow sections carved out of `shmorch-core.md`
  (kept as reference material, loaded on demand). `shmorch-core.md` 257 → 203 lines
  (~21% cut) — the always-on kernel now covers only what's needed every session; the
  moved sections are consulted at specific moments (a commit, a PR, a checkpoint), not
  every turn.
- **Front-matter previews** — `docs/state/*.md` files (not `tracks/`, not `schedule/`)
  now open with a 3-line `status`/`updated`/`summary` YAML block (convention documented in
  `core/documentation.md` § Front-Matter Previews). `docs/state/index.md` is the skeleton
  index that surfaces these; `orient.md` gained a new **Step 0 — pulse check** that reads
  it first, before the full Step 1–3 reads. Applied to `templates/docs/state/` (seeded to
  new projects) and to this repo's own `docs/state/plan.md` / `session.md`
  (`docs/state/index.md` created here too — this repo had none before).
- This is a narrower version of the original "~10-line skeleton index" idea: front matter
  lives on the files themselves rather than a single separate summary file, and the
  convention is `docs/state/`-scoped rather than a new artifact to keep in sync.

## Split out

- **Phase 3 — store shape** (evaluate a graph/wiki backend for state so `go` pulls the
  current-focus subgraph, not whole files) moved to its own track:
  `tracks/20260717-state-store-shape/index.md`. It was blocking this track's closure on a
  decision with no committed timeline; splitting it lets entrypoint-consolidation close on
  its actual (dispatcher + context-trim) scope. The Beads store-shape candidate write-up
  moved there too.

## Deferred

- Optional: physically merge `init.md` + `auto-update.md` into one `provision.md` (low
  value; only if a single file proves clearly simpler in practice). Still parked here —
  it's about the dispatcher, not the store shape.

## Work log

### 2026-07-07

- Carved `orient.md`; rewrote `go.md` as the state dispatcher; routed UNINITIALIZED→init,
  BEHIND→auto-update, added resumable overlay; updated `shmorch-core.md` session-start;
  tagged the engines. Verified state routing by trace + no dangling step refs. VERSION → 20260707.04.
- Added the **shallow-orientation guardrail**: `orient` reads only `docs/state/*` + git metadata; no reading/grepping/analyzing source code (or spawning discovery) until the user gives a directive after `go`. Carved the same exception into `shmorch-core.md`'s "Always keep moving" line (the root cause). VERSION → 20260707.05.
- Moved the Beads-compatibility mapping out of the live `navigate.md` into this track (Phase 3 store-shape candidate) and cross-linked the `plan.md` Beads item. navigate.md VERSION → 20260707.07.

### 2026-07-17

- Landed Phase 2: carved `core/operations.md` out of `shmorch-core.md` (Timing/Comms/Vacuum/
  Checkpoints/Version sections), registered it in `core/index.md`; added the front-matter
  preview convention (`core/documentation.md`), applied it to `templates/docs/state/` and
  this repo's own `docs/state/`, created this repo's first `docs/state/index.md`, and added
  `orient.md` Step 0 to read it. VERSION → 20260717.01.
- Split Phase 3 (store shape) out to `tracks/20260717-state-store-shape/index.md` — moved
  the Beads candidate write-up with it, since this track's own scope (dispatcher +
  context trim) is now fully landed. Track closed.
