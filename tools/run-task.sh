#!/usr/bin/env bash
# run-task.sh — Invoke a Claude agent as a subprocess and return its text output
# Usage: bash ~/.claude/skills/shmorch/tools/run-task.sh <role> <prompt>
#
# Manages session IDs per role so agents maintain context across turns.
# Writes session state to docs/state/agents/<role>.json in the project root.
#
# Output: the agent's text response (from Claude's JSON envelope)
# Exit 1: if Claude fails or agent returns no status signal

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

ROLE="${1:-}"
PROMPT="${2:-}"

if [ -z "$ROLE" ] || [ -z "$PROMPT" ]; then
  echo "Usage: bash ~/.claude/skills/shmorch/tools/run-task.sh <role> <prompt>" >&2
  exit 1
fi

STATE_FILE="docs/state/agents/${ROLE}.json"
mkdir -p docs/state/agents

# resume an existing session if one exists for this role
SESSION_ID=$(jq -r '.session_id // empty' "$STATE_FILE" 2>/dev/null || true)
RESUME_ARG=""
[ -n "$SESSION_ID" ] && RESUME_ARG="--resume $SESSION_ID"

# invoke Claude as a subprocess
RAW=$(claude $RESUME_ARG \
  -p "$PROMPT" \
  --output-format json \
  --permission-mode bypassPermissions \
  --max-turns 20)

# persist the new session ID for the next turn
NEW_SESSION_ID=$(echo "$RAW" | jq -r '.session_id // empty')
if [ -n "$NEW_SESSION_ID" ]; then
  echo "{\"session_id\":\"$NEW_SESSION_ID\",\"role\":\"$ROLE\"}" > "$STATE_FILE"
fi

# return the agent's text response
echo "$RAW" | jq -r '.result // empty'
