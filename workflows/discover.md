# Workflow: discover

Deep audit of an existing codebase. Fills in `docs/state/context.md` and `docs/state/stack.md` from what's actually in the project — not from guesses.

## When to use
- After `init` on an existing project
- Any time the state files feel stale relative to the real code
- When onboarding to an unfamiliar codebase

## Inputs
- The project directory (all paths relative to project root)

## Roles
- `agents/roles/analyst.md` (one per major code directory, run in parallel)

---

> **Read `.shmorch/agents/TASK-PROTOCOL.md` before starting.**

All paths relative to the project root.

---

## Step 1 — Stamp
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "discover: starting codebase audit"
```

---

## Step 2 — Structural sweep (parallel, no agents needed)

Run all of these in parallel directly (no Task needed — these are quick reads, not analysis):

**A — Top-level layout**
List all non-hidden top-level dirs and files (exclude: `node_modules`, `target`, `dist`, `build`, `.git`, `shmorch`, `env*`, `venv*`). Note what each major directory appears to contain.

**B — Dependency files**
Find and read: `requirements*.txt`, `pyproject.toml`, `Pipfile`, `package.json`, `Cargo.toml`, `go.mod`, `Gemfile`, `composer.json`, `pom.xml`, `build.gradle`. Extract: framework, key libraries, pinned versions.

**C — Runtime constraints**
Find and read: `runtime.txt`, `.python-version`, `.nvmrc`, `.ruby-version`, `.tool-versions`, `Procfile`, `.github/workflows/*.yml`. Note: what runtime version is pinned and what pins it.

**D — Entry points**
Find: `manage.py`, `app.py`, `main.py`, `index.js`, `main.go`, `Program.cs`, `artisan`, `bin/`, `cmd/`, `src/main*`. Read first 30 lines of any found.

**E — README**
Read `README.md` / `README.rst` (first 60 lines). Extract project description.

**F — Test setup**
Find test directories (`tests/`, `test/`, `spec/`, `__tests__/`). Identify framework.

---

## Step 3 — Code structure sweep (Call Task — parallel analysts)

Identify major code directories from Step 2A (up to 4). For each, call Task in parallel:

```
Task(
  description: "Analyst: <dirname>",
  prompt: |
    ## Role
    Read your role: check `.shmorch/agents/roles/analyst.md` first (project override); if not present, use `~/.claude/skills/shmorch/agents/roles/analyst.md` (skill default). Act according to the role definition found.

    ## Task
    Analyze the directory: <dirname>
    - List all files
    - Read key files (models, services, controllers, routes — whatever fits the stack)
    - Identify what this module does, key classes/functions, notable patterns

    ## Output
    Write your findings to: docs/state/analysis-<dirname>-discover.md

    Structure:
    ### What this module does
    ### Key elements
    ### Notable patterns
    ### External dependencies
    ### Flags
    - [CRUFT] <dead or unused code>
    - [BLOCKER] <broken or clearly outdated>
    - [GAP] <missing tests or documentation>

    ## Return
    DONE: docs/state/analysis-<dirname>-discover.md | <one-line summary> [| BLOCKER | CRUFT | GAP]
)
```

Stamp each spawn:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_SPAWN" "analyst → <dirname>"
```

---

## Step 4 — Gate

After all Task calls complete:
- Verify each `docs/state/analysis-<dirname>-discover.md` exists. Re-run missing ones.
- If any return contains `BLOCKER`: note it — surface in the final report but do not stop synthesis.
- Stamp:
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "AGENT_DONE" "analyst → docs/state/analysis-<dirname>-discover.md"
```

---

## Step 5 — Synthesize

After all parallel work completes, write:

**`docs/state/context.md`** — fill every section with real findings:
- Project name and what it does (from README + entry points)
- Tech stack summary
- Existing codebase: list key directories
- Leave Preferences and Never Do as `<!-- fill in -->` — developer sets those

**`docs/state/stack.md`** — fill every section:
- Runtime: version and what pins it
- Key dependencies: top 8–12 with versions and purpose
- External constraints: hosting, API versions, upgrade limits
- Best practice notes: 1–2 bullets per major framework component
- Leave Upgrade Opportunities empty

**Update `docs/state/session.md`**:
```
## Latest Session
Discovery completed on DATE.
Codebase analyzed: [list of dirs scanned].
context.md and stack.md filled in — review before first session.
```

---

## Step 6 — Stamp
```bash
bash ~/.claude/skills/shmorch/tools/timelog.sh "PHASE" "discover: complete"
```

---

## Step 7 — Report and hand off

Print:
- What the project does (1–2 sentences)
- Stack detected
- Any [BLOCKER] or [CRUFT] flags worth knowing upfront
- Which state files were written

Ask: "Want to review what I found, or jump straight into working on something?"

If review: walk through `docs/state/context.md` and `docs/state/stack.md`, let them correct anything.
If work: transition to the `go` flow (read `workflows/go.md` from Step 4 onward — skip re-reading context/stack since we just wrote them).
