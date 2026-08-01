# Workflow: self-improve

Retrospective self-improvement. Reads session history and timelog to surface friction patterns, then proposes targeted changes to shmorch's own workflows and commands.

## When to use
- Automatically at the end of every `wrap` session (lightweight mode)
- Manually after a frustrating session, after a sprint closes, when `docs/inbox/` has accumulated items

## Inputs
- `docs/project/timelog.md`
- `docs/project/session.md`
- `docs/inbox/` (project) or `$SHMORCH_HOME/docs/inbox/` (skill, if no project inbox exists) — one file per captured observation
- `docs/{product,technology}/decisions/ (topic-appropriate)`

## Roles
- `agents/roles/researcher.md` (introspective mode)

---

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

---

## Step 1 — Stamp
```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "self-improve: starting"
```

---

## Step 2 — Check for evidence

```bash
bash $SHMORCH_HOME/tools/check-self-improve-gate.sh
```

If output starts with `SKIP:` — tell the user which condition triggered and exit.
If output is `PROCEED` — continue to Step 3.

---

## Step 3 — Gather evidence (parallel reads, no agents)

Read in parallel:
- `docs/project/timelog.md` **tail only** — it's append-only and grows without bound; never `Read` it whole. Use `tail -200 docs/project/timelog.md` to look for repeated patterns: stalled phases, re-run agents, frequent BLOCKERs
- `docs/project/session.md` — friction noted across recent sessions
- `docs/inbox/*.md` (project) — manually captured observations; if the project has no `docs/inbox/`, fall back to `$SHMORCH_HOME/docs/inbox/*.md` (skill's own inbox)
- `docs/{product,technology}/decisions/ (topic-appropriate)` — decisions later revised or reversed

Also run these structural checks and capture output as evidence:

**Fat project workflow files** (not using Extends pattern):
```bash
for f in .shmorch/workflows/*.md; do
  [ -f "$f" ] || continue
  [[ "$(basename $f)" == "README.md" ]] && continue
  head -3 "$f" | grep -q "^# Extends:" || echo "FAT COPY CANDIDATE: $f"
done
```
Any file flagged is a full copy that will silently diverge from skill updates. Include in researcher evidence as a graduation or trimming candidate — the project-specific parts may belong in the skill, or the file just needs to be rewritten as a thin Extends stub.

**Scaffold reverse check** (docs/ dirs not in canonical template):
```bash
EXPECTED_DOCS="docs docs/project docs/project/tracks docs/project/schedule docs/project/process docs/product docs/product/strategy docs/product/design docs/product/features docs/product/decisions docs/technology docs/technology/architecture docs/technology/development docs/technology/decisions docs/reference docs/reference/instructions docs/reference/research docs/inbox"
LOG=".shmorch/project_docs_log.md"
LOGGED=""
[ -f "$LOG" ] && LOGGED=$(grep -v '^#' "$LOG" 2>/dev/null)
find docs -maxdepth 2 -mindepth 1 -type d | grep -v "^docs/project/tracks/" | sort | while read d; do
  echo "$EXPECTED_DOCS" | grep -qw "$d" && continue
  # A dir is covered if it's logged directly, or nested under a logged top-level dir
  echo "$LOGGED" | grep -qxF "$d" && continue
  echo "$LOGGED" | while read logged; do [ -n "$logged" ] && [[ "$d" == "$logged"/* ]] && exit 0; done && continue
  echo "UNLISTED DIR: $d"
done
```

If any `UNLISTED DIR` entries appear, include them in the researcher's evidence as potential structural drift — the canonical scaffold may need updating, or the dir is project-specific and belongs in `.shmorch/project_docs_log.md`.

**Note:** `.shmorch/project_docs_log.md` is a project-local, append-only log of project-specific doc/folder additions that aren't part of the canonical scaffold. It is not checked in to the shmorch skill. Keep it small: log only the top-level dir (e.g. `docs/reference/schwab`) — anything created underneath an already-logged dir does not need its own line. When creating a new docs/ dir that isn't in `EXPECTED_DOCS`, check this file and append a line if the dir isn't already covered.

---

## Step 4 — Call Task (researcher, introspective mode)

```
Task(
  description: "Researcher: self-improve — retrospective analysis",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/researcher.md` first (project override); if not present, use `$SHMORCH_HOME/agents/roles/researcher.md` (skill default). Act according to the role definition found.
    You are operating in INTROSPECTIVE mode: analyze internal evidence only, no web search.

    ## Task
    Review the shmorch session evidence:
    - docs/project/timelog.md
    - docs/project/session.md
    - docs/inbox/*.md (project), or $SHMORCH_HOME/docs/inbox/*.md if no project inbox exists
    - docs/{product,technology}/decisions/ (topic-appropriate)

    Identify friction patterns (minimum 2 occurrences to count as a pattern):
    - Workflow phases that appear repeatedly before completing (stalling)
    - Commands invoked in unexpected sequences
    - BLOCKER flags that recur across sessions
    - Workarounds noted in session notes
    - Decisions revisited or reversed

    Before proposing a pattern, cross-check whether it was already resolved: grep
    `docs/{product,technology}/decisions/ (topic-appropriate)` and `.shmorch/AGENTS.md` (or `CLAUDE.md`) for a prior
    entry addressing the same concern. If found, do not re-propose it as an open pattern —
    list it under "Already addressed" instead, citing the resolving commit/PR/decision entry.
    Only propose patterns that evidence shows are still live.

    For each remaining pattern, propose a specific change to a shmorch file:
    - Which file (commands/, workflows/, agents/roles/, shmorch-core.md)
    - What specifically to add, remove, or rewrite
    - Why this pattern indicates a gap

    ## Output
    Write proposals to: ~/.claude/self-improve-<YYYYMMDD>-<project-slug>.md

    Where <project-slug> is the basename of the working directory (e.g. "mobos", "myapp").
    One file per project per date — multiple projects may write notes on the same date
    without conflict because filenames include the project slug.

    **IMPORTANT: NEVER write self-improve output to the project's `docs/project/` directory.**
    The `~/.claude/` location is deliberate — self-improve output is a shmorch tool artifact,
    not a project document. Writing to the project mixes tool output with project state and
    creates cruft that must be manually cleaned up.

    Structure:
    ### Self-Improve Proposals — <date> | Project: <project-slug>

    #### Proposal N: <title>
    **Pattern:** <what the evidence shows>
    **Frequency:** <how often>
    **File:** <path>
    **Change:** <specific text or structural change>
    **Improvement:** <what gets better>

    ### Already addressed
    <patterns whose resolution was found in decisions.md/AGENTS.md/CLAUDE.md — cite the resolving commit/PR>

    ### No-action observations
    <patterns seen once — keep for next run>

    ## Return
    DONE: ~/.claude/self-improve-<YYYYMMDD>-<project-slug>.md | <N proposals> [| BLOCKER if evidence files missing]
)
```

Stamp:
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_SPAWN" "researcher → self-improve"
```

---

## Step 5 — Gate

Verify `~/.claude/self-improve-<date>-<project-slug>.md` exists.
```bash
bash $SHMORCH_HOME/tools/timelog.sh "AGENT_DONE" "researcher → ~/.claude/self-improve-<date>-<project-slug>.md"
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

**Before branching for this proposal:** check open PR count against the branch cap in
`core/git-discipline.md` (`gh pr list --state open | wc -l`). If already at 2-3+ open
PRs, stop the proposal loop here — surface to the developer: "N proposals reviewed, M PRs
open (at/above cap). Merge or close existing PRs before continuing, or batch the
remaining proposals onto a single branch instead of one-per-PR."

1. `cd $SHMORCH_HOME`
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

**Project-local changes** (`.shmorch/workflows/` overrides, `.shmorch/AGENTS.md`):
- Apply directly to the project file — no PR needed
- Bump `.shmorch/VERSION`

---

## Step 7 — Clear addressed inbox items and stamp

Before scanning for *new* classifications, first re-sweep any inbox item left PARTIAL or
UNADDRESSED by a prior self-improve run whose PRs have since merged (check
`docs/project/session.md` for "PR/commit status" lines listing merges since that item's
last-touched date) — re-classify against current (post-merge) skill files before adding
new findings.

Scan `docs/inbox/*.md` (project) or `$SHMORCH_HOME/docs/inbox/*.md` (skill, if no project inbox exists) — skip `index.md`. For each file, classify it mechanically:

```bash
# For each inbox file, grep for its core concern in skill files
grep -r "<keyword from the inbox item>" $SHMORCH_HOME/shmorch-core.md \
  $SHMORCH_HOME/workflows/*.md 2>/dev/null | head -3
```

Classification:
- **ADDRESSED** — the concern is reflected verbatim or substantively in a skill file → delete the file now; do not leave it as archive (git history carries it)
- **PARTIAL** — the concept exists but the specific proposal isn't implemented → prepend `_(partial — <what's missing>)_` to the file and keep it in place
- **UNADDRESSED** — not found in any skill file → keep the file as-is; include in no-action observations in the proposals output

Record the cleanup in the proposals file:

```
### Inbox cleanup — <date>
Removed: <N files> (addressed). Kept: <M files> (partial/unaddressed).
```

- Append to `docs/project/session.md`: `Self-improve <date>: N proposals, M applied.`

```bash
bash $SHMORCH_HOME/tools/timelog.sh "PHASE" "self-improve: complete — <M> changes applied"
```
