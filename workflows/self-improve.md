# Workflow: self-improve

Retrospective self-improvement. Reads session history and timelog to surface friction patterns, then proposes targeted changes to shmorch's own workflows and commands.

## When to use
- Automatically at the end of every `wrap` session (lightweight mode)
- Manually after a frustrating session, after a sprint closes, when NOTES.md has accumulated items

## Inputs
- `docs/state/timelog.md`
- `docs/state/session.md`
- `.shmorch/NOTES.md` (if present)
- `docs/development/decisions.md`

## Roles
- `agents/roles/researcher.md` (introspective mode)

---

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## Step 1 — Stamp
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "self-improve: starting"
```

---

## Step 2 — Check for evidence

```bash
bash ~/.claude/skills/shmorch/tools/check-self-improve-gate.sh
```

If output starts with `SKIP:` — tell the user which condition triggered and exit.
If output is `PROCEED` — continue to Step 3.

---

## Step 3 — Gather evidence (parallel reads, no agents)

Read in parallel:
- `docs/state/timelog.md` — repeated patterns: stalled phases, re-run agents, frequent BLOCKERs
- `docs/state/session.md` — friction noted across recent sessions
- `.shmorch/NOTES.md` — manually recorded issues (may not exist)
- `docs/development/decisions.md` — decisions later revised or reversed

Also run the scaffold reverse check and capture output as evidence:

```bash
EXPECTED_DOCS="docs docs/state docs/state/tracks docs/state/schedule docs/product docs/development docs/architecture docs/reference docs/development/guides docs/development/testing"
find docs -maxdepth 2 -mindepth 1 -type d | grep -v "^docs/state/tracks/" | sort | while read d; do
  echo "$EXPECTED_DOCS" | grep -qw "$d" || echo "UNLISTED DIR: $d"
done
```

If any `UNLISTED DIR` entries appear, include them in the researcher's evidence as potential structural drift — the canonical scaffold may need updating to match actual usage.

---

## Step 4 — Call Task (researcher, introspective mode)

```
Task(
  description: "Researcher: self-improve — retrospective analysis",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/researcher.md` first (project override); if not present, use `~/.claude/skills/shmorch/agents/roles/researcher.md` (skill default). Act according to the role definition found.
    You are operating in INTROSPECTIVE mode: analyze internal evidence only, no web search.

    ## Task
    Review the shmorch session evidence:
    - docs/state/timelog.md
    - docs/state/session.md
    - .shmorch/NOTES.md (if present)
    - docs/development/decisions.md

    Identify friction patterns (minimum 2 occurrences to count as a pattern):
    - Workflow phases that appear repeatedly before completing (stalling)
    - Commands invoked in unexpected sequences
    - BLOCKER flags that recur across sessions
    - Workarounds noted in session notes
    - Decisions revisited or reversed

    For each pattern, propose a specific change to a shmorch file:
    - Which file (commands/, workflows/, agents/roles/, shmorch-core.md)
    - What specifically to add, remove, or rewrite
    - Why this pattern indicates a gap

    ## Output
    Write proposals to: ~/.claude/self-improve-<YYYYMMDD>-<project-slug>.md

    Where <project-slug> is the basename of the working directory (e.g. "mobos", "myapp").
    One file per project per date — multiple projects may write notes on the same date
    without conflict because filenames include the project slug.

    Structure:
    ### Self-Improve Proposals — <date> | Project: <project-slug>

    #### Proposal N: <title>
    **Pattern:** <what the evidence shows>
    **Frequency:** <how often>
    **File:** <path>
    **Change:** <specific text or structural change>
    **Improvement:** <what gets better>

    ### No-action observations
    <patterns seen once — keep for next run>

    ## Return
    DONE: ~/.claude/self-improve-<YYYYMMDD>-<project-slug>.md | <N proposals> [| BLOCKER if evidence files missing]
)
```

Stamp:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "researcher → self-improve"
```

---

## Step 5 — Gate

Verify `~/.claude/self-improve-<date>-<project-slug>.md` exists.
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "researcher → ~/.claude/self-improve-<date>-<project-slug>.md"
```

If no proposals: tell the user "No patterns found — sessions look clean." Stamp and exit.

---

## Step 6 — Review with developer

Present each proposal one at a time:

> "Proposal N: <title>
> Pattern: <observed>
> Change: <specific>
> Apply? (yes / no / modify)"

**Two targets — different workflows for each:**

**Skill-level changes** (`commands/`, `shmorch-core.md`, `agents/`, `tools/`, `workflows/` in the skill):
1. `cd ~/.claude/skills/shmorch`
2. `git checkout -b <type>/YYYYMMDD-<concept>` — type is `feature`, `bug`, or `upgrade`
3. Apply the changes to skill files
4. Bump `VERSION` to `YYYYMMDD.NN`
5. Use `/smart-commit` to stage and commit
6. `git push -u origin <branch>`
7. Create PR:
   ```bash
   gh pr create --title "<type>(shmorch): <concept>" --body "$(cat <<'EOF'
   ## Summary
   - <bullet per proposal applied>

   ## Pattern observed
   <what the evidence showed>

   🤖 Generated with Shmorch self-improve
   EOF
   )"
   ```
8. `git checkout main` — return to main after PR is open; do NOT merge

**Project-local changes** (`.shmorch/workflows/` overrides, `.shmorch/CLAUDE.md`):
- Apply directly to the project file — no PR needed
- Bump `.shmorch/VERSION`

---

## Step 7 — Clear and stamp

- Scan `.shmorch/NOTES.md` for every item. For each one, check whether it has been fully addressed (promoted to a skill file, workflow, or decisions.md). Remove addressed items immediately — do not leave them as archive. The file should only contain unactioned notes.
- Append to `docs/state/session.md`: `Self-improve <date>: N proposals, M applied.`

```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "self-improve: complete — <M> changes applied"
```
