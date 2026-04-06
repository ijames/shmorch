#!/usr/bin/env bash
# timelog.sh — Append a timestamped event to state/timelog.md
# Usage: bash tools/timelog.sh "EVENT" "detail"
# Examples:
#   bash tools/timelog.sh "SESSION_START" "resuming auth module"
#   bash tools/timelog.sh "TASK_START" "Build login endpoint"
#   bash tools/timelog.sh "AGENT_SPAWN" "analyst → src/payments/"
#   bash tools/timelog.sh "TASK_DONE" "Build login endpoint"
#   bash tools/timelog.sh "SESSION_END" "spec approved"

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

EVENT="${1:-EVENT}"
DETAIL="${2:-}"
TS=$(date '+%Y-%m-%d %H:%M:%S')
ENTRY="[$TS] $EVENT | $DETAIL"

echo "$ENTRY" >> state/timelog.md
echo "$ENTRY"
