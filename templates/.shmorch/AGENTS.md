@~/.claude/skills/shmorch/shmorch-core.md

---

## Project Overrides — PROJECT_NAME

### What This Project Does
<!-- fill in -->

### Tech Stack
<!-- fill in — e.g. "Python/FastAPI, PostgreSQL, Docker" -->

### Permission Matrix

**Run without asking:**
- Read files, list files, run tests, run linter on single file, run tsc --noEmit on single file
- Tag files or code blocks for vacuum/deletion (note the tag, but do not delete)

**Always ask first:**
- Package installs (npm/pip/etc.), git push, actually deleting files, running full build
- Adding new dependencies, changing package.json / requirements / lock files

Where possible, encode prohibitions as lint rules with remediation instructions — markdown instructions alone are probabilistic.

### Branching Discipline

Every track gets its own branch. No direct-to-main commits except hotfixes confirmed by the user.

**Branch naming:** `feat/YYYYMMDD-<slug>` · `fix/YYYYMMDD-<slug>` · `docs/YYYYMMDD-<slug>`

**PR merge strategy:** <!-- merge | squash | rebase — see decisions.md for rationale -->
- `merge` — preserves branch topology in DAG, parallel work visible in graph forever
- `squash` — one commit per PR, granular history lost, topology lost
- `rebase` — granular history preserved, topology lost

**Use:** `gh pr merge --STRATEGY`

### Docs Placement Hook

**Status:** <!-- enabled | disabled — default disabled until asked -->

When enabled, a `PostToolUse` hook fires right after each docs file is written or edited —
while it's still the only thing in view, not batched up with everything else touched that
session — and reminds to apply the vacuumer role's docs-placement check
(`agents/roles/vacuumer.md`) then and there. Opt-in: ask once during the context interview;
toggle any time by editing this line.

### Never Do Without Asking
<!-- fill in — e.g. "delete records", "push to main", "change schema" -->
