---
loads_when: intake or setup for a Python project, or any Python lint/format tooling decision
size: 21 lines
---

# Python

Ruff is the default linter and formatter for Python projects — it replaces flake8,
pyflakes, pycodestyle, isort, and black for everything it covers. `uv` is the default
package manager (see `technologies/javascript.md` — pnpm is the JS/TS analogue for the
same worktree/shared-cache reasoning).

## flake8: kept only for what Ruff hasn't absorbed

Ruff does not support third-party plugins and has no native rule for class
member/method ordering as of 2026-09 (tracked upstream: astral-sh/ruff issues
[#10261](https://github.com/astral-sh/ruff/issues/10261) and
[discussion #16051](https://github.com/astral-sh/ruff/discussions/16051)). Until Ruff
ships this natively, keep a minimal flake8 install scoped to just
[flake8-class-attributes-order](https://pypi.org/project/flake8-class-attributes-order/)
(enforces the step-down ordering in `core/engineering-standards.md` § Code organization)
alongside Ruff, not instead of it. Don't let flake8 creep back into covering anything
Ruff already handles.

**Removal trigger:** when Ruff ships a native class/method-ordering rule, drop flake8 and
the plugin entirely and switch the config to Ruff's rule. Check the linked issue/discussion
during any Python project's tooling setup or upgrade pass — this is the kind of
decision-that-implies-a-later-code-change flagged in
`docs/inbox/decisions-vs-directives.md`; don't let the flake8 dependency outlive its reason
for existing.
