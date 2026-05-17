#!/usr/bin/env bash
# parse-status.sh — Extract status and summary from an agent's response text
# Usage: bash tools/parse-status.sh <field> <<< "$response_text"
#        echo "$response_text" | bash tools/parse-status.sh <field>
#
# <field> is "status" or "summary"
# Looks for the last JSON object containing a "status" field in the input.
# Exits 1 if no status signal is found.

set -euo pipefail

FIELD="${1:-status}"
INPUT=$(cat)

# extract the last JSON object that contains a "status" field
MATCH=$(echo "$INPUT" | grep -o '{"status":"[^"]*"[^}]*}' | tail -1 || true)

if [ -z "$MATCH" ]; then
  echo "error: no status signal found in agent response" >&2
  exit 1
fi

echo "$MATCH" | jq -r ".${FIELD} // empty"
