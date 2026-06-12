↑ [Shmorch Plan](../../plan.md)
→ `shmorch-core.md` refactored into `core/*.md` sub-documents

# Track: shmorch-core.md breakup

**Status:** Open
**Opened:** 2026-06-01
**Domain:** Skill architecture

## Why

`shmorch-core.md` has grown into a god doc — identity, rules, workflow phases, timing events, safety rules, and version management all in one file. It loads in full at every session start, consuming context tokens that can't be used for downstream project work. This measurably degrades code quality in projects: wrong imports, skipped verification, shallow reasoning on complex tasks.

## What changes

Break `shmorch-core.md` into focused sub-documents under `core/`, each loaded JIT by the workflow or role that needs it. Result: a lean `shmorch-core.md` that contains only session bootstrap directives and a pointer table. Full content lives in named `core/` files.

Prerequisite for: boundary-cleanup track.

## Work log

### 2026-06-01
Identified during DarkBadge session. Context consumption at session start confirmed as the root cause of downstream code quality issues.
