# Command: help

Print Shmorch command reference.

## When to run
- Any time the user wants a quick overview of available commands

## Steps

Output this to the user:

```
Shmorch — autonomous development orchestrator

SESSION
  /shmorch go [topic]       Start or resume a session. Reads state, orients, proposes next move.
                             Runs auto-update check and environment check automatically.
  /shmorch wrap             Close session. Updates session.md, plan.md, decisions.md, closes
                             timelog. Self-improve runs automatically — no need to run it separately.
  /shmorch checkpoint       Save shmorch state to git (safe restore point).

SETUP
  /shmorch init [path]      Initialize Shmorch in a project (new or existing). Creates .shmorch/,
                             docs/state/, doc skeleton, hooks, and shmorch.sh launcher.
  /shmorch discover         Deep audit of existing codebase. Fills context.md and stack.md
                             from what's actually built, not what was planned.
  /shmorch auto-update      Bring project shmorch files up to date with current skill version.
                             Runs file diff then semantic comparison. Offers missing scaffold dirs.
                             Runs automatically when go detects a VERSION gap.

WORK
  /shmorch commit           Analyze all changes, group into independent logical units, and commit
                             each with a clean message. Includes tests, docs, and track updates.
  /shmorch vacuum           Scan for dead code, stale docs, orphaned tests. Flag and propose cleanup.
                             Run before committing to keep history clean.
  /shmorch documentarian    Audit docs/code/tests parity. Verify closed tracks delivered knowledge
                             to their destination docs. Find undocumented features, stale content,
                             and skeleton gaps — feed them to the backlog.

END-OF-SESSION SEQUENCE (suggested)
  1. /shmorch vacuum        Catch waste before it's committed.
  2. /shmorch commit        Group and commit changes cleanly.
  3. /shmorch wrap          Persist state. Self-improve runs automatically.

PLANNING
  /shmorch status            Quick project health snapshot — sprint day, open/done tasks, test
                             counts, recent commits, and one risk or next-step call.
  /shmorch sprinter          Show current sprint status and flag risks.
  /shmorch sprinter new      Start a new sprint — goal, dates, scope, definition of done.
  /shmorch sprinter close    Close sprint, update track outcomes, archive to docs/state/schedule/.
  /shmorch prioritize        Re-rank full backlog by value, effort, blocking, and risk.
  /shmorch prioritize sprint Re-rank within current sprint scope only.

SELF-IMPROVEMENT
  /shmorch self-improve     Retrospective: surface friction from session history, propose targeted
                             changes to shmorch workflows and commands. Runs automatically at wrap.
                             Run manually after a frustrating session or when NOTES.md has items.
  /shmorch research         External: search for latest AI dev practices and Claude Code releases,
                             propose specific applicable changes to shmorch. Best run at sprint
                             start or after a major Anthropic release.

ANYTHING ELSE
  /shmorch <question or directive>
    Treat as a question or task addressed to Shmorch in the current project context.
    Reads state and responds as active development lead.

LAUNCHING
  ./shmorch.sh              Preferred launcher — sets CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
                             for parallel agent spawning, then runs claude.
  claude                    Works but agent teams run sequentially. Shmorch will warn you.

RESTORE
  Esc+Esc or /rewind        Restore to a previous session checkpoint (30 days)
```
