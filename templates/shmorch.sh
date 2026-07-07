#!/usr/bin/env bash
# Shmorch launcher — starts your agent CLI in this project with the context chain loaded.
# Pick the CLI with --cli=<name> or $SHMORCH_CLI; otherwise the first one found wins.
# Any CLI also works when started directly here — the AGENTS.md/CLAUDE.md chain loads regardless.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Resolve the skill install dir and export it for tools + hooks.
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$(cat .shmorch/home 2>/dev/null || true)"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"
export SHMORCH_HOME

CLI="${SHMORCH_CLI:-}"
for arg in "$@"; do
  case "$arg" in --cli=*) CLI="${arg#--cli=}" ;; esac
done

# Auto-detect if unset: first available wins.
if [ -z "$CLI" ]; then
  for c in omp claude codex gemini opencode cursor-agent; do
    if command -v "$c" >/dev/null 2>&1; then CLI="$c"; break; fi
  done
fi

echo ""
echo "Starting Shmorch — $(basename "$PWD")  [CLI: ${CLI:-none found}]"
echo "  /shmorch go    — start session   ·   /shmorch help — all commands"
echo ""

case "$CLI" in
  claude)
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    exec claude --dangerously-skip-permissions
    ;;
  omp)      exec omp ;;
  codex)    exec codex ;;
  gemini)   exec gemini ;;
  opencode) exec opencode ;;
  *)
    if [ -n "$CLI" ] && command -v "$CLI" >/dev/null 2>&1; then exec "$CLI"; fi
    echo "No supported agent CLI found. Install one (omp, claude, codex, gemini, opencode)" >&2
    echo "or set \$SHMORCH_CLI / pass --cli=<name>." >&2
    exit 1
    ;;
esac
