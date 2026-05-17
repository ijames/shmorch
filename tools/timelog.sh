#!/usr/bin/env bash
# timelog.sh — Append a timestamped event to docs/state/timelog.md
# Usage: bash ~/.claude/skills/shmorch/tools/timelog.sh "EVENT" "detail"
# Examples:
#   bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_START" "resuming auth module"
#   bash ~/.claude/skills/shmorch/tools/timelog.sh "TASK_START" "Build login endpoint"
#   bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "analyst → src/payments/"
#   bash ~/.claude/skills/shmorch/tools/timelog.sh "TASK_DONE" "Build login endpoint"
#   bash ~/.claude/skills/shmorch/tools/timelog.sh "SESSION_END" "spec approved"

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

EVENT="${1:-EVENT}"
DETAIL="${2:-}"
TS=$(date '+%Y-%m-%d %H:%M:%S')
ENTRY="[$TS] $EVENT | $DETAIL"

echo "$ENTRY" >> "$ROOT/docs/state/timelog.md"
echo "$ENTRY"
