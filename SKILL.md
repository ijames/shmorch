---
name: shmorch
description: Shmorch is an autonomous development orchestrator that manages persistent project state across sessions. Use this skill whenever the user wants to start a dev session, plan features, track in-progress work, clean up code, manage a sprint, prioritize work, or improve the shmorch workflow itself. Trigger on /shmorch go, resume, init, discover, wrap, commit, vacuum, checkpoint, sprinter, prioritize, self-improve, research, status, or auto-update — or when they say things like "let's start a session", "what were we working on", "clean up the code", "check the sprint", "reprioritize the backlog", "what's the status", or "look for better practices".
user-invocable: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Agent, WebSearch
---

Dispatch on the first word of the invocation arguments — `$ARGUMENTS` on Claude Code, the `User:` directive after `/skill:shmorch` on omp, or the words following `shmorch` when typed as plain text on any other CLI. Read **only** the matching command file, then execute it.

| Argument | File to read |
|---|---|
| `init` | `commands/init.md` |
| `discover` | `commands/discover.md` |
| `go` | `commands/go.md` |
| `resume` | `commands/resume.md` |
| `wrap` | `commands/wrap.md` |
| `commit` | `commands/commit.md` |
| `vacuum` | `commands/vacuum.md` |
| `checkpoint` | `commands/checkpoint.md` |
| `auto-update`, `sync`, or `update` | `commands/auto-update.md` |
| `sprinter` | `commands/sprinter.md` |
| `prioritize` | `commands/prioritize.md` |
| `self-improve` | `commands/self-improve.md` |
| `research` | `commands/research.md` |
| `status` | `commands/status.md` |
| `help` or empty | `commands/help.md` |
| anything else | **Shmorch prompt** — treat the full args as a question or directive addressed to Shmorch in the current project context. Read `docs/state/context.md`, `docs/state/session.md`, and `docs/state/plan.md` to orient, then respond as Shmorch: actively, concisely, and with a next-step proposal. Do not read any command file. |

Do not read command files you don't need — they're large and only the relevant one matters.
