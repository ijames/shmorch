#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export SHMORCH_SELF=1
echo ""
echo "Starting Shmorch — $(basename "$PWD")"
echo "  Running /shmorch go automatically."
echo "  After go completes, Esc+Esc rewinds to this point — reclaim context anytime."
echo "  /shmorch help  — all commands"
echo ""
claude --dangerously-skip-permissions "/shmorch go"
