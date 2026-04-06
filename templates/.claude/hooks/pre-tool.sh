#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
if echo "$CMD" | grep -qE "rm -rf|rm -r /|git push --force"; then
  echo '{"decision": "block", "reason": "Destructive op blocked. Confirm with user."}'; exit 2
fi
exit 0
