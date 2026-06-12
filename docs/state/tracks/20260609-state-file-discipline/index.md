↑ [Shmorch Plan](../../plan.md)
→ `workflows/commit.md`, `workflows/build.md`, `workflows/wrap.md` + new track state protocol

# Track: State file discipline — tracks own their state

**Status:** Open
**Opened:** 2026-06-09
**Domain:** Skill architecture

## Why

Root-level `docs/state/` files (`session.md`, `plan.md`, `timelog.md`) are being committed to feature branches. When PRs merge, these cause genuine merge conflicts: each branch's session/plan/timelog changes are additive and sequential, not resolvable by picking one side.

The correct model: per-track state lives entirely inside `docs/state/tracks/<trackname>/` for the track's full lifecycle. Root-level state files are only updated on `dev` directly, at graduation/merge time, as a deliberate consolidation step.

Source: MoBoS PR merge conflicts 2026-06-09.

## What changes

1. `commit.md` and `build.md` must never `git add docs/state/session.md`, `plan.md`, or `timelog.md` when on a feature branch
2. `wrap.md` graduation step consolidates track state into root-level files on `dev` after merge
3. Any shmorch command that writes session/plan/timelog must detect the current branch and write to the track directory instead
4. Document the canonical rule: root-level state = `dev`-only; feature branch state = track directory

## Work log

### 2026-06-09
Surfaced from MoBoS PR merge conflicts — multiple branches each updating session.md and plan.md caused non-resolvable conflicts at merge time.
