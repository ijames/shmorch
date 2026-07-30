---
status: open
category: Architecture
---

↑ [Plan](index.md)

**Shared state branch: git-decoupled state layer** — state files conflict on every branch merge because git's divergence model and shared mutable state are structurally incompatible. Candidate: orphan `state` branch + permanent git worktree at `.shmorch-state/`; state lives outside the branch graph entirely. Supersedes state-file-discipline if adopted. → [track](../tracks/20260614-shared-state-branch/index.md)

---
