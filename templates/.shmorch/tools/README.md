# .shmorch/tools/

This directory is reserved for **project-local overrides** only.

Since shmorch `20260516.01`, all standard tool scripts live in the skill at:

```
~/.claude/skills/shmorch/tools/
```

They are called from workflows via absolute path and work in any project via `git rev-parse --show-toplevel` — no project copies needed.

**When to put something here:** only if you have a project-specific shell operation that doesn't belong in the skill. The bar is high — most things belong upstream.
