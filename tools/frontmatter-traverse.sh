#!/usr/bin/env bash
# frontmatter-traverse.sh — resolve which .md files under a root are relevant to a
# query by reading only their frontmatter, never their body.
#
# Usage: bash tools/frontmatter-traverse.sh <root-dir> <query> [--all]
#
#   root-dir  Directory to scan (e.g. $SHMORCH_HOME/core, $SHMORCH_HOME/workflows)
#   query     Case-insensitive substring matched against each file's `loads_when`
#             field. A file matches if `loads_when` contains query and `skip_when`
#             (if present) does not. Files with no frontmatter always match (can't
#             be gated, so the caller must open them to decide) and are marked
#             UNGATED in the output so gaps are visible, not silent.
#   --all     Ignore query — print every file's frontmatter fields, for the "grep
#             frontmatter across a flat set of siblings" fallback (approach-a.md
#             step 4) when there's no single index to disambiguate.
#
# Output: one line per matched file — "<path>\t<reason>" — never a file body.
# This is one flat pass over frontmatter blocks, not a body read, no matter how
# many files are under root-dir: cost scales with file count, not file size.
#
# See docs/project/tracks/20260721-workflow-subagent-delegation/approach-a-frontmatter-gating.md

set -euo pipefail

ROOT="${1:?usage: frontmatter-traverse.sh <root-dir> <query> [--all]}"
QUERY="${2:-}"
MODE="${3:-}"

if [[ ! -d "$ROOT" ]]; then
  echo "frontmatter-traverse: directory not found: $ROOT" >&2
  exit 1
fi

# extract_field FILE FIELD — value of a top-level "field: value" line inside the
# leading --- ... --- frontmatter block. Empty if absent or file has no frontmatter.
extract_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    NR==1 && $0 != "---" { exit }
    NR==1 { infm=1; next }
    infm && $0 == "---" { exit }
    infm && $0 ~ "^" f ":" {
      sub("^" f ":[[:space:]]*", "")
      print
      exit
    }
  ' "$file"
}

has_frontmatter() {
  [[ "$(head -1 "$1" 2>/dev/null)" == "---" ]]
}

while IFS= read -r -d '' file; do
  if ! has_frontmatter "$file"; then
    echo -e "${file}\tUNGATED (no frontmatter — open to decide)"
    continue
  fi

  loads_when="$(extract_field "$file" "loads_when")"
  skip_when="$(extract_field "$file" "skip_when")"

  if [[ "$MODE" == "--all" ]]; then
    summary="$(extract_field "$file" "summary")"
    echo -e "${file}\tloads_when=${loads_when:-<none>} skip_when=${skip_when:-<none>} summary=${summary:-<none>}"
    continue
  fi

  [[ -z "$QUERY" ]] && { echo "frontmatter-traverse: query required unless --all" >&2; exit 1; }

  q_lc="$(printf '%s' "$QUERY" | tr '[:upper:]' '[:lower:]')"
  loads_lc="$(printf '%s' "$loads_when" | tr '[:upper:]' '[:lower:]')"
  skip_lc="$(printf '%s' "$skip_when" | tr '[:upper:]' '[:lower:]')"

  if [[ -n "$skip_lc" && "$loads_lc" == *"$q_lc"* && "$skip_lc" == *"$q_lc"* ]]; then
    continue # skip_when wins on an ambiguous double-match
  fi
  if [[ -n "$skip_lc" && "$skip_lc" == *"$q_lc"* ]]; then
    continue
  fi
  if [[ -n "$loads_lc" && "$loads_lc" == *"$q_lc"* ]]; then
    echo -e "${file}\tmatched loads_when"
  fi
done < <(find "$ROOT" -maxdepth 1 -name "*.md" -print0 | sort -z)
