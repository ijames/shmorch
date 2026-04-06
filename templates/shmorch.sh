#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
chmod +x .claude/hooks/stop.sh .claude/hooks/pre-tool.sh 2>/dev/null || true
chmod +x tools/*.sh 2>/dev/null || true
echo ""
echo "Starting Shmorch...  (/rewind or Esc+Esc to restore any state)"
echo ""
claude
