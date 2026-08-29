---
status: open
category: process
---

**Backfill: migrate existing Claude Code project memory into repo docs** — every
Shmorch-managed project's `~/.claude/projects/<slug>/memory/*.md` has been silently
accumulating durable feedback/decision/user-profile content that belongs in that
project's own repo docs instead. `block-claude-project-memory-writes` (this same batch)
stops new writes going forward; this item is the one-time cleanup of what's already
there.

**Scope**, one project at a time (each is a separate repo with its own branch/PR
conventions):

1. Read every `*.md` in `~/.claude/projects/<slug>/memory/` (skip `MEMORY.md`) and its
   `metadata.type` (`user`/`feedback`/`project`/`reference`).
2. Verify which real project the content belongs to by content, not just the directory
   slug — a session can touch multiple projects in one conversation (found one entry, a
   DarkBadge naming rule, sitting in `shming.com`'s memory for exactly this reason).
3. Migrate into that project's own repo:
   - `feedback`/`project` describing a decision or incident → dated entry in
     `docs/technology/decisions/index.md` or `docs/product/decisions/index.md`
     (Context/Decision/Rationale, matching existing entries).
   - `user` (collaboration style) → a "Working With James" section under
     `.shmorch/AGENTS.md` Project Overrides.
   - `reference` → that project's `docs/reference/`.
   - Duplicates content already documented elsewhere → delete outright, no migration.
4. Write the migrated content, delete the memory file, update that project's `MEMORY.md`
   index.

Filed from `shming.com` 2026-08-26 (found while cleaning up its own memory folder: five
files, one belonging to DarkBadge, one duplicating `~/.shmorch/personal-profile/README.md`,
the rest migrated by hand). Per the actor-model rule, the filing session did not touch any
other project's memory folder or this skill's own inbox mechanics beyond filing — this
backlog item is the explicit pickup point.
