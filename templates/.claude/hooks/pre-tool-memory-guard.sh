#!/usr/bin/env bash
set -euo pipefail
[ -d ".shmorch" ] || exit 0
INPUT=$(cat)
PATH_ARG=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
if echo "$PATH_ARG" | grep -qE '/\.claude/projects/[^/]+/memory/.*\.md$'; then
  echo '{"decision": "block", "reason": "Durable content belongs in this repo'\''s docs, not Claude Code project memory (invisible to git/PR review, does not survive clone or CLI switch). Feedback/decisions -> docs/technology/decisions/ or docs/product/decisions/. Collaboration notes -> .shmorch/AGENTS.md Project Overrides. Project state -> docs/project/session.md or plan/."}'
  exit 2
fi
exit 0
