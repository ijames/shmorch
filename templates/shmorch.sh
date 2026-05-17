#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
chmod +x shmorch/tools/*.sh .claude/hooks/*.sh 2>/dev/null || true
echo ""
echo "Starting Shmorch — $(basename "$PWD")"
echo "  /shmorch go    — start session"
echo "  /shmorch help  — all commands"
echo "  Esc+Esc or /rewind anytime to restore a previous state"
echo ""
claude --dangerously-skip-permissions
