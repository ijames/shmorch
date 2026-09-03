---
loads_when: intake or setup for a JS/TS project — pnpm as default, worktree/node_modules sharing, uv as the Python analogue
size: 32 lines
---

# JavaScript / TypeScript

pnpm is the default package manager for JS/TS projects: new projects, and existing projects
with no committed lockfile (`package-lock.json` / `yarn.lock`) yet. Existing npm/yarn projects
with a committed lockfile are not force-migrated — adopt pnpm going forward, don't churn history
to switch an established project.

## Why

`git worktree`-based parallel builds (used for multi-agent track work) don't share `node_modules`
under plain npm — every new worktree needs a full fresh install before typechecking resolves
correctly, and skipping it silently leaves type-checking broken. This happened on treeclusion: a
worktree's `tsc` ran against the wrong/empty `node_modules` and missed a real error.

pnpm's content-addressed store hardlinks into each worktree, so installs go from a
sometimes-skipped slow step to ~1s regardless of worktree count. Same class of gap as npm's
flat/duplicated `node_modules` vs. `uv`'s shared cache for Python — `uv` is the Python analogue
and deserves the same "prefer for new projects" precedent.

## Rule

- New JS/TS project → `pnpm init`, not `npm init`.
- Existing project, no committed lockfile → switch to pnpm before the first install.
- Existing project, committed `package-lock.json`/`yarn.lock` → leave as-is unless the developer
  asks to migrate.
- Worktree-based parallel builds on an npm project (not yet migrated) → flag the shared
  `node_modules` risk explicitly before trusting a worktree's typecheck result.
