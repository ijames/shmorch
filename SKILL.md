---
name: shmorch
description: Shmorch is an autonomous development orchestrator that manages persistent project state across sessions. Use this skill whenever the user wants to start a dev session, plan features, track in-progress work, clean up code, or commit changes in a project that has a shmorch/ directory. Also use it when the user runs /shmorch go, /shmorch init, /shmorch discover, /shmorch wrap, /shmorch commit, /shmorch vacuum, or /shmorch checkpoint — or when they say things like "let's start a session", "what were we working on", "save our progress", or "clean up the code".
user-invocable: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Agent
---

Dispatch on the first word of `$ARGUMENTS`. Read **only** the matching command file, then execute it.

| Argument | File to read |
|---|---|
| `init` | `commands/init.md` |
| `discover` | `commands/discover.md` |
| `go` | `commands/go.md` |
| `wrap` | `commands/wrap.md` |
| `commit` | `commands/commit.md` |
| `vacuum` | `commands/vacuum.md` |
| `checkpoint` | `commands/checkpoint.md` |
| `update` | `commands/update.md` |
| `help` or empty | `commands/help.md` |

Do not read command files you don't need — they're large and only the relevant one matters.
