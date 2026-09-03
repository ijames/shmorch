# Technologies

Optional, per-technology context — the opposite of `core/`. `core/` is doctrine every
project needs regardless of stack; this directory is notes for a *specific* technology
choice (a language, a cloud, an IaC tool) that only matters when a project's stack
actually includes it. Most technologies never need an entry here — this exists for the
ones opinionated or gotcha-prone enough to warrant one (e.g. `git worktree` +
package-manager caching behavior). A disciplined stack (e.g. Go) may never need a file.

↑ parent: skill root

## How to use

Given a project's tech stack (`docs/project/stack.md` /
`docs/technology/development/tech-stack.md`), when work touches one of the technologies
listed below, load its file for the tooling/convention notes that apply. Don't load
speculatively — this is JIT context, not background reading.

| Technology | File |
|---|---|
| JavaScript / TypeScript | `technologies/javascript.md` |
| Python | `technologies/python.md` |

No fixed taxonomy here — a new file gets added the moment a technology (a language, a
cloud provider, an IaC tool, a database) proves opinionated enough to need one. No
subfolder structure until there's enough content per-technology to warrant it.
