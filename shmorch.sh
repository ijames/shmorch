#!/usr/bin/env bash
# Shmorch self-dev launcher — opens the skill repo itself as a shmorch-managed project.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export SHMORCH_HOME="$PWD"
export SHMORCH_SELF=1

CLI="${SHMORCH_CLI:-claude}"
for arg in "$@"; do
  case "$arg" in --cli=*) CLI="${arg#--cli=}" ;; esac
done

echo ""
echo "Starting Shmorch (self-dev) — $(basename "$PWD")  [CLI: $CLI]"
echo "  /shmorch go — orient and start a session"
echo "  /shmorch resume — fast lane if a session was interrupted"
echo "  /shmorch help — all commands"
echo ""

case "$CLI" in
  claude)
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    exec claude --dangerously-skip-permissions
    ;;
  *) exec "$CLI" ;;
esac
