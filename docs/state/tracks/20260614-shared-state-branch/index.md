---
status: Investigation
updated: 2026-06-14
summary: Evaluating an orphan `state` git branch + permanent worktree to decouple mutable state files from the branch merge graph entirely; supersedes state-file-discipline if adopted.
---

↑ [State File Discipline](../20260609-state-file-discipline/index.md)
→ [Architecture: Decisions](../../../development/decisions.md), [Plan](../../plan.md)

# Track: Shared State Branch — Git-Decoupled State Layer

**Status:** Investigation
**Opened:** 2026-06-14
**Domain:** Architecture

## Why

Shmorch commits state files (`docs/state/session.md`, `docs/state/plan.md`, `docs/state/timelog.md`) to the same branch as skill/code files. When multiple feature branches are in flight and all append to plan.md independently, merges conflict — and no `.gitattributes` strategy survives multiple branches with independent appended histories. The user's instinct: "it's almost a hardlink situation."

Git's branching model is designed for divergence. Shared mutable state is the opposite. These two things are structurally in conflict and require a structural solution, not a workflow workaround.

This is the deeper problem that `20260609-state-file-discipline` was pointing at without fully naming.

## Problem statement

- State files change on every session, on every branch
- Merging any two branches that touched state produces conflicts
- `merge=ours` drops changes; `merge=union` is best-effort on structured markdown
- The only clean solution is for state files to live outside the branch graph entirely

## Candidate approaches

### A — Orphan `state` branch + git worktree (preferred hypothesis)
- `state` is an orphan branch (no shared history with `main`)
- Checked out as a permanent side-worktree at `.shmorch-state/` inside the project
- Feature branches never contain state files — they're `.gitignore`d in the main worktree
- Shmorch tools write to `$STATE_DIR` (env var, defaults to `docs/state/`) allowing gradual migration
- Worktree auto-initialized by `init`; `auto-update` checks it exists
- State commits are purely linear — no merging ever needed

### B — External state directory (`~/.shmorch-state/<project-id>/`)
- State lives outside the repo entirely, keyed by project root hash
- No git involvement in state at all
- Upside: zero conflict ever, works across branch switches instantly
- Downside: state not portable across machines without separate sync; no git history for state

### C — Convention only (do nothing structural)
- Enforce "never commit state on feature branches" via pre-commit hook
- State only ever committed directly to `main`/`dev`
- Conflicts still possible if two sessions on different machines; doesn't help multi-machine

## Open questions

1. **Worktree portability** — orphan worktrees don't clone automatically. Does `init` need to create and push the `state` branch, or can it be local-only?
2. **Multi-machine sync** — if the worktree is local-only, how does state stay in sync across machines? Push/pull the `state` branch separately?
3. **How deep is the git coupling?** — shmorch already leans on `git log`, `git rev-parse`, `commit-session-state.sh`. A full decoupling to option B may require more refactoring than the value justifies.
4. **Can `$STATE_DIR` abstraction be added non-breakingly?** — all tools currently hardcode `docs/state/`. Threading `$STATE_DIR` through every tool is a real migration cost.
5. **Is the problem actually painful enough yet?** — this only bites when multiple branches are active simultaneously. At solo-dev cadence, is option C (hook guard) sufficient for now?

## Work log

### 2026-06-14

Surfaced during discussion about git subtree / hardlink alternatives. User's framing: "I'm afraid we're already conjoined" — meaning shmorch's design already assumes git is the state store, so decoupling is non-trivial.

Agreed: open investigation track before diverging further into git internals. No implementation yet.

Hypothesis: Option A (orphan branch + worktree) is the right long-term answer. Option C (hook guard) may be sufficient as a short-term gate while the architecture is investigated.

Related: `20260609-state-file-discipline` — that track captured the discipline rule (don't commit state on feature branches). This track asks the harder question: what's the right substrate for state if not the main branch graph?
