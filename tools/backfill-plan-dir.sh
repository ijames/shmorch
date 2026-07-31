#!/usr/bin/env bash
# Migrates a project's flat docs/project/plan.md into docs/project/plan/ —
# index.md (frontmatter + Current Task + Completed, hand-maintained) plus one
# file per open backlog item (category + status frontmatter). Backlog items
# become independently addable files so concurrent stub tracks never collide
# on a shared plan.md edit; index.md is only touched when Current Task or
# Completed changes.
#
# Mechanical split only. Run from the target project's repo root, or pass
# its path as $1.
set -euo pipefail
ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

OLD="docs/project/plan.md"
NEW="docs/project/plan"

if [ ! -f "$OLD" ]; then
  echo "No $OLD found under $ROOT. Nothing to do."
  exit 0
fi
if [ -d "$NEW" ]; then
  echo "$NEW already exists — already migrated. Nothing to do."
  exit 0
fi

mkdir -p "$NEW"

python3 - "$OLD" "$NEW" <<'PYEOF'
import re, sys, os

old_path, new_dir = sys.argv[1], sys.argv[2]
text = open(old_path).read()

fm_match = re.match(r'^---\n(.*?\n)---\n', text, re.S)
frontmatter = fm_match.group(0) if fm_match else ""
rest = text[len(frontmatter):]

def section(name, body):
    m = re.search(rf'^## {re.escape(name)}\n(.*?)(?=\n^## |\Z)', body, re.S | re.M)
    return m.group(1).strip("\n") if m else ""

current_task = section("Current Task", rest)
backlog = section("Backlog", rest)
completed = section("Completed", rest)

slugs = set()
def slugify(title):
    s = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
    base, i = s, 2
    while s in slugs:
        s = f"{base}-{i}"
        i += 1
    slugs.add(s)
    return s

item_count = 0
category = None
for block in re.split(r'\n(?=### |\n- \[ \] )', backlog):
    block = block.strip("\n")
    if not block:
        continue
    cat_match = re.match(r'^### (.+)$', block)
    if cat_match:
        category = cat_match.group(1).strip()
        continue
    item_match = re.match(r'^- \[ \] \*\*(.+?)\*\*(.*)$', block, re.S)
    if not item_match or category is None:
        continue
    title, tail = item_match.group(1).strip(), item_match.group(2)
    slug = slugify(title)
    body = f"**{title}**{tail}".strip("\n")
    out = f"---\nstatus: open\ncategory: {category}\n---\n\n{body}\n"
    open(os.path.join(new_dir, f"{slug}.md"), "w").write(out)
    item_count += 1

index = frontmatter + "\n# Shmorch Plan\n\n" if "Shmorch Plan" in text else frontmatter + "\n# Plan\n\n"
index += (
    "> **What belongs here:** What to build and in what order.\n"
    "> Backlog items live as individual files in this directory (one per item, `category`/`status`\n"
    "> frontmatter) so concurrent work never collides on a shared edit — add a new file, don't\n"
    "> edit this index. `index.md` only changes for Current Task or Completed updates.\n"
    "> Changes here do NOT bump VERSION (docs are internal; only skill file changes affect VERSION).\n\n"
    "---\n\n## Current Task\n\n"
    + (current_task if current_task else "_(none yet)_")
    + "\n\n---\n\n## Completed\n\n"
    + (completed if completed else "<!-- Items closed here when the skill change is merged to main. -->")
    + "\n"
)
open(os.path.join(new_dir, "index.md"), "w").write(index)

print(f"Split {item_count} backlog item(s) into {new_dir}/, wrote index.md.")
PYEOF

git rm -q "$OLD"
git add "$NEW"

echo ""
echo "Migrated $OLD -> $NEW/. Review the split, then commit."
