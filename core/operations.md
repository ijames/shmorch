---
loads_when: before touching any skill file, cutting a PR, or logging a timing event — timing events, comms notifications, vacuum protocol, checkpoints, VERSION bump rule, branch/PR workflow
size: 116 lines
---

# Operations

Reference material for routine mechanics — timing, notifications, checkpoints, and the
skill-change workflow. Loaded on demand, not held in the always-on kernel
(`shmorch-core.md`) since these are consulted at specific moments, not every turn.

---

## Timing — Log These Events

Use `bash "$SHMORCH_HOME/tools/timelog.sh" "EVENT" "detail"` at every transition:

| When | Event | Detail |
|---|---|---|
| Session opens | `SESSION_START` | topic or "resuming X" |
| Task begins | `TASK_START` | task name from plan/ |
| Agent spawned | `AGENT_SPAWN` | "role → target" |
| Agent done | `AGENT_DONE` | "role → output file" |
| Phase changes | `PHASE` | e.g. "intake → spec" |
| Task completes | `TASK_DONE` | task name |
| Vacuum runs | `VACUUM` | area scanned |
| Session closes | `SESSION_END` | one-line summary |

Run `bash "$SHMORCH_HOME/tools/duration.sh" today` anytime to see elapsed times.

---

## Communication Notifications

If a communication MCP is connected (e.g. Zulip), post a brief update on every significant
event — track promoted, architectural decision made, commit, feature decision, task/phase
switch. Do not ask — just post. Use your CLI's MCP tools for that server (Claude
`mcp__zulipchat__get_streams`, omp `mcp://…`) to find the right channel; pick the most
appropriate one. Sign messages `— Shmorch`. Occasionally check what users have posted to
integrate with docs and planning.

---

## Vacuum Protocol

At reflection points, and on noticing stale TODOs, dead tests, or orphaned docs: run
`/shmorch vacuum`.

---

## Checkpoints

- Use your CLI's checkpoint/restore if it has one (Claude Code `Esc Esc` / `/rewind`,
  30-day; omp `rewind` / `checkpoint` tools). Not every CLI has this.
- Bash commands are not part of conversation checkpoints.
- `/shmorch checkpoint` → save shmorch state to git — the CLI-neutral restore point that
  works everywhere.

---

## Version

Current version: see `.shmorch/VERSION`. To pull skill upgrades into this repo, run
`/shmorch sync` (alias `/shmorch update`).

**VERSION bump rule:** `VERSION` is semantic (`MAJOR.MINOR.PATCH`, since `1.0.0` —
2026-08-04, see `docs/project/tracks/20260804-semver-versioning/`; before that it was
`YYYYMMDD.NN`). Any edit to skill files (`shmorch-core.md`, `workflows/*.md`, `agents/**`,
`commands/*.md`, `core/*.md`, `tools/*.sh`) must immediately bump both `.shmorch/VERSION`
and `$SHMORCH_HOME/VERSION`:

- **MAJOR** — a `Compat: backfill` Architecture Changelog entry (see
  `core/documentation.md`), a template/scaffold structure change, or a change to the
  versioning scheme itself.
- **MINOR** — a new command, workflow, or role.
- **PATCH** — any other skill-file tweak or fix.

If a change qualifies for more than one tier, use the highest. `docs/` changes do NOT bump
VERSION.

**Skill change workflow:** Branch → PR → developer merges. Never commit directly to
`main`.

1. `git fetch --all`
2. `git checkout main && git pull js main` — always fork from a current main
3. `git checkout -b <type>/YYYYMMDD-<concept>`
4. Make changes + bump VERSION
5. `git push -u js <branch>`
6. `gh pr create` — title: `<type>(shmorch): <concept>`
7. `git checkout main` — do NOT self-merge

**Cross-repo discipline — actor model, not direct manipulation.** The branch → PR →
developer-merge flow above is for sessions running *in* `$SHMORCH_HOME` itself
(self-hosting shmorch). A session working in a different project must never `cd
$SHMORCH_HOME` and branch/commit/push against the skill repo directly, even if it has
correctly diagnosed a real skill gap — that project has no standing to mutate the skill's
innards, only to message it. Instead it writes a proposal file to
`$SHMORCH_HOME/docs/inbox/<concept>.md` (same shape as any other inbox item — see
`docs/inbox/index.md`) describing the gap, the evidence, and the suggested change, and
stops there. A shmorch session later running in `$SHMORCH_HOME` picks it up like any
other inbox item (`self-improve` or a manual pass) and only then runs the branch → PR →
merge flow above, from inside the skill repo. This keeps every skill-repo commit
attributable to a session that was actually in that repo, and keeps other projects'
self-improve output from silently drafting PRs against a repo they don't own.

**After the developer merges any PR** — mandatory before any other action:

```bash
git fetch --all
git checkout main
git pull js main
```

Then rebase every remaining open branch onto the freshly-pulled main before resuming work
or merging it. Never batch-merge without pulling between each merge. Full doctrine:
`core/git-discipline.md`

**The shmorch skill is itself a shmorch-managed project.** `docs/` at
`$SHMORCH_HOME/docs/` is the live project documentation for shmorch. `templates/docs/`
contains blank stubs seeded to new repos by `/shmorch init`. Never mix these. `init` must
not be run on `$SHMORCH_HOME` itself — the guard in `workflows/init.md` prevents this.
