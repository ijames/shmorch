---
status: Open
category: process
updated: 2026-07-31
---

# Watch self-improve output and backfill execution

**Why this exists:** the 2026-07-30 self-improve run produced 9 proposals that all became
independent PRs and sat unmerged for a full extra session before landing (this session,
2026-07-31) — merging required resolving a VERSION collision and several real content
conflicts at every step. Self-improve proposing faster than PRs get merged is a recurring
risk, not a one-off.

Separately, this batch shipped two backfill-relevant changes that need to actually reach
already-provisioned consuming projects, not just exist on `main`:
- `tools/backfill-plan-dir.sh` (PR #78, `plan.md` → `plan/` directory registry)
- The existing `tools/backfill-docs-taxonomy.sh` chain (PR #78 hooks the above into it)

**What to watch, going forward:**
1. **Don't let self-improve PRs stack up.** Merge each proposal's PR at the point it's
   opened (or within the same session) rather than batching many open PRs for a later
   merge sweep — the later the sweep, the more VERSION/content conflicts compound.
2. **When a consuming project runs `/shmorch sync` or `auto-update`,** confirm the
   `plan/` directory backfill and the docs-taxonomy backfill are actually offered and
   applied — don't assume the tooling landing on `main` means it reaches existing
   projects automatically.
3. Revisit `docs/project/plan/index.md`'s "Self-improve" note under Current Task (already
   flags that self-improve proposes+PRs independently) — this item extends that with the
   concrete backfill-verification piece.
