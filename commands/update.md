# Command: update

Bidirectional sync between this project's shmorch files and the skill template.

- **Downstream:** skill template → project (pull in generic improvements)
- **Upstream:** project → skill template (contribute improvements back)
- **Project-specific:** extract into `shmorch/CLAUDE.md` overrides, not lost

---

## Step 1 — Check versions

Read `shmorch/VERSION` (the project's current version).
Read `~/.claude/skills/shmorch/VERSION` (the latest skill version).

```bash
PROJECT_VERSION=$(cat shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
SKILL_VERSION=$(cat ~/.claude/skills/shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
echo "Project: $PROJECT_VERSION"
echo "Skill:   $SKILL_VERSION"
```

Version format is `YYYYMMDD.NN.NN` (e.g. `20260401.00`). The `.NN` sub-version allows multiple releases per day.

- If they match: tell the user "Already up to date (version YYYYMMDD.NN.NN)." and stop.
- If the project version is older: show "Project is at YYYYMMDD.NN.NN, skill is at YYYYMMDD.NN.NN."

---

## Step 2 — Semantic diff of each tracked file

For each file listed below, read both the project version and the skill template version and compare them semantically (not just line-by-line). Classify every difference as one of:

| Class | Meaning |
|---|---|
| `project-specific` | Reflects this project's domain, stack, or preferences — should stay in the project |
| `generic-improvement` | Makes the tool better for any project — worth pushing upstream |
| `conflict` | Both sides changed the same concept in incompatible ways — needs user decision |
| `identical` | No meaningful difference |

**Tracked files:**

- `shmorch/shmorch-core.md`
- `shmorch/workflows/*.md`
- `shmorch/agents/orchestrator.md`
- `shmorch/agents/roles/*.md`
- `shmorch/tools/*.sh`

Skip `shmorch/state/**`, `shmorch/CLAUDE.md`, `shmorch/VERSION` — never touch these.

---

## Step 3 — Present findings

Show a summary table:

```
File                              | Status   | Project-specific | Generic improvement | Conflict
----------------------------------|----------|-----------------|--------------------|---------
shmorch-core.md                   | modified | 2 changes       | 1 change           | 0
workflows/build.md                | modified | 0               | 3 changes          | 1
agents/roles/implementer.md       | identical| —               | —                  | —
...
```

For each non-identical file, briefly describe what changed and how it was classified. Be concise — one line per change.

---

## Step 4 — Propose actions

Based on the analysis, propose three buckets:

### A. Extract to project overrides (`shmorch/CLAUDE.md`)
Project-specific changes that are currently embedded in generic files. These should be moved into `shmorch/CLAUDE.md` so the generic file can be cleanly updated from upstream.

List each change and where in `shmorch/CLAUDE.md` it would live.

### B. Push upstream to skill template
Generic improvements in the project's files that would benefit all shmorch users. These would update the skill template files at `~/.claude/skills/shmorch/templates/`.

List each change.

### C. Conflicts requiring user decision
Cases where both the skill template and the project file changed the same concept. Present both versions and ask the user which to keep (or how to merge).

---

## Step 5 — Confirm

Ask the user to confirm each bucket:
- "Extract these N project-specific changes to CLAUDE.md?" (yes/no/review)
- "Push these N generic improvements upstream?" (yes/no/review)
- For each conflict: "Which version do you want?" (project / skill / merge)

Wait for responses before proceeding.

---

## Step 6 — Apply

Execute only what the user confirmed:

1. **Extract project-specific changes:** Append them to `shmorch/CLAUDE.md` under a clearly labelled section. Then copy the clean skill template version of the file into the project.

2. **Push upstream:** Write the improved content to the skill template files at `~/.claude/skills/shmorch/templates/`. Tell the user: "Upstream updated — these changes are now part of your local skill and will apply to future `/shmorch init` projects."

3. **Resolve conflicts:** Apply the chosen version.

4. **Copy remaining files** (identical or fully resolved) from skill template to project.

5. **Update VERSION** — always bump both sides to today's date:
```bash
TODAY=$(date +%Y%m%d)
# Determine .NN suffix (increment if already edited today)
CURRENT_SKILL=$(cat ~/.claude/skills/shmorch/VERSION 2>/dev/null | tr -d '[:space:]')
if [[ "$CURRENT_SKILL" == ${TODAY}.* ]]; then
  NN=$(echo "$CURRENT_SKILL" | cut -d. -f2)
  NN=$(printf "%02d" $((10#$NN + 1)))
else
  NN="00"
fi
NEW_VERSION="${TODAY}.${NN}"
echo "$NEW_VERSION" > ~/.claude/skills/shmorch/VERSION
echo "$NEW_VERSION" > shmorch/VERSION
echo "Version bumped to $NEW_VERSION"
```

**Rule: any edit to shmorch skill or template files requires bumping the VERSION.** Do not leave VERSION stale after edits — this is what allows `update` to detect drift.

---

## Step 7 — Report

- "Updated shmorch from YYYYMMDD.NN to YYYYMMDD.NN."
- List what was extracted to CLAUDE.md, pushed upstream, and resolved.
- Remind the user: "Review `shmorch/CLAUDE.md` to confirm the extracted overrides look right."
