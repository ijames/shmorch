↑ [Inbox](index.md)

# New core doctrine: pnpm precedent for JS/TS projects

**Issue (2026-07-29):** On treeclusion, `git worktree` (used for parallel/multi-agent track builds per branching discipline) doesn't share `node_modules` across worktrees. With plain npm, every new worktree needed a full fresh install before `tsc`/build would even resolve types — either a slow per-worktree tax or an easy-to-skip step that silently leaves type-checking broken (this actually happened: a worktree's `tsc` ran against the wrong/empty `node_modules` and missed a real type error until pnpm was adopted and the install became fast enough to just do). Switching treeclusion to pnpm (global content-addressed store, hardlinked into each worktree's `node_modules`) fixed it — installs went from "needs npm install, sometimes skipped" to ~1s, no matter how many worktrees are open. The developer confirmed this should be the standing precedent for all Shmorch-managed JS/TS repos, not a one-off fix.

**What to consider:**
- Draft content ready to drop in as `core/js_tooling.md`: pnpm as the default for new JS/TS projects and for existing projects with no committed lockfile yet (adoption, not migration — don't force-convert a project already on an established npm/yarn habit); rationale as above; a short note that `uv` is the Python analogue (global content-addressed cache, hardlinked into venvs) and should get the same "prefer for new projects" precedent, since `pip`/`poetry`/`conda` all still duplicate per-venv.
- Add a row to `core/index.md`'s table once the file lands.
- No `.shmorch/VERSION` / `$SHMORCH_HOME/VERSION` bump has been done — that's part of the skill-change workflow once this graduates out of the inbox, not before.
