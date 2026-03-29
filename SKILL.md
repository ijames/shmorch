---
name: shmorch
description: Shmorch orchestration commands. Usage: /shmorch <command> — init, go, sync, commit, vacuum, checkpoint, help
user-invocable: true
allowed-tools: Bash(bash shmorch/*), Bash(git *), Read, Edit, Write, Grep, Glob, Agent
---

Dispatch on the first word of `$ARGUMENTS`.

@commands/help.md
@commands/init.md
@commands/go.md
@commands/sync.md
@commands/commit.md
@commands/vacuum.md
@commands/checkpoint.md

Read the command matching the first word of `$ARGUMENTS` and execute it.
If `$ARGUMENTS` is empty or is "help", run the help command.
