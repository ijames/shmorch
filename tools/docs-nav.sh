#!/usr/bin/env bash
# docs-nav.sh — patch sibling navigation links into every doc in a docs/ tree
#
# Usage: bash tools/docs-nav.sh [docs-root]
# Default docs-root: docs/  (relative to current working directory)
#
# For each directory containing an index.md, reads the sibling .md files,
# extracts their # Title headings, and writes an "In this section:" nav line
# immediately after the ↑ up-link in each sibling. Safe to re-run — replaces
# the nav line on subsequent runs.

set -euo pipefail

DOCS="${1:-docs}"

if [[ ! -d "$DOCS" ]]; then
  echo "docs-nav: directory not found: $DOCS" >&2
  exit 1
fi

patched=0
skipped=0

# join_with SEP elem [elem ...]
join_with() {
  local sep="$1"; shift
  local result=""
  for item in "$@"; do
    [[ -z "$result" ]] && result="$item" || result+="${sep}${item}"
  done
  printf '%s' "$result"
}

while IFS= read -r index_file; do
  dir="$(dirname "$index_file")"

  # Collect sibling .md files (sorted, excluding index.md itself)
  sibling_files=()
  while IFS= read -r f; do
    sibling_files+=("$f")
  done < <(find "$dir" -maxdepth 1 -name "*.md" ! -name "index.md" | sort)

  [[ ${#sibling_files[@]} -eq 0 ]] && continue

  # Build nav parts: [Title](filename.md)
  nav_parts=()
  for sib in "${sibling_files[@]}"; do
    bname="$(basename "$sib")"
    title="$(grep -m1 '^# ' "$sib" 2>/dev/null | sed 's/^# //' | tr -d '\r')"
    [[ -z "$title" ]] && title="${bname%.md}"
    nav_parts+=("[${title}](${bname})")
  done

  nav_line="**In this section:** $(join_with ' · ' "${nav_parts[@]}")"

  # Patch each sibling
  for sib in "${sibling_files[@]}"; do
    if ! grep -q '^↑' "$sib" 2>/dev/null; then
      skipped=$((skipped + 1))
      continue
    fi

    tmp="$(mktemp)"
    # Remove any existing nav line, then insert fresh one after the ↑ line
    awk -v nav="$nav_line" '
      /^\*\*In this section:/ { next }
      /^↑/                    { print; print nav; next }
      { print }
    ' "$sib" > "$tmp"
    mv "$tmp" "$sib"
    patched=$((patched + 1))
  done

done < <(find "$DOCS" -name "index.md" | sort)

echo "docs-nav: patched ${patched} file(s)${skipped:+, skipped ${skipped} (no ↑ link)}"
