↑ [Inbox](index.md)

# Learning log should be a Shmorch directive, not a per-project docs folder

**Issue (2026-08-13):** shmorch-core.md already directs: "When a concept surfaces that
the developer clearly didn't have context for, add it to `docs/reference/learning.md`
without being asked." That log lives per-project (DarkBadge has
`docs/reference/learning/`), but most captured concepts (pnpm, uv, SSR hydration, GEO,
etc.) aren't project-specific — they're true on any project the developer touches next.

**What to consider:**
- Since the whole capture behavior is already a Shmorch directive (not a separate tool
  or skill), the fix belongs in Shmorch's own state, not a new mechanism — likely
  `~/.shmorch/learning/` (or similar global, user-owned location), parallel to how
  Claude Code's own memory system already does global + per-project linkback.
- Project docs would keep a link back to the global entry rather than owning the content
  directly. Global entries could carry a "seen in: <project>" list for provenance.
- Open questions: exact location (ships-with-skill vs user-owned dir), dedup behavior
  when the same concept resurfaces in two projects, and updating the
  shmorch-core.md capture directive to point at the new location.
- Raised while merging DarkBadge PR #196 (learning-log split into per-concept files) —
  thinking-out-loud stage only, not scoped or committed to.
