# Command: discover

Deep audit of an existing codebase. Fills in `state/context.md` and `state/stack.md` from what's actually in the project — not from guesses.

Run this after `init` on an existing project, or any time the state files feel stale relative to the real code.

All paths relative to the project root.

---

## Step 1 — Stamp

```bash
bash shmorch/tools/timelog.sh "PHASE" "discover: starting codebase audit"
```

---

## Step 2 — Structural sweep (parallel)

Run all of these in parallel:

**A — Top-level layout**
List all non-hidden top-level dirs and files (exclude: `node_modules`, `target`, `dist`, `build`, `.git`, `shmorch`, `env*`, `venv*`). Note what each major directory appears to contain.

**B — Dependency files**
Find and read:
- `requirements*.txt`, `pyproject.toml`, `Pipfile`, `Pipfile.lock`
- `package.json`, `package-lock.json`, `yarn.lock`
- `Cargo.toml`, `go.mod`, `Gemfile`, `Gemfile.lock`, `composer.json`, `pom.xml`, `build.gradle`

Extract: framework, key libraries, pinned versions.

**C — Runtime constraints**
Find and read:
- `runtime.txt`, `.python-version`, `.nvmrc`, `.ruby-version`, `.tool-versions`
- `Procfile`, `app.yaml`, `app.json`
- `.github/workflows/*.yml`, `.travis.yml`, `circle.yml`, `tox.ini`, `pytest.ini`

Note: what runtime version is pinned, and what is doing the pinning (platform, CI, local tool).

**D — Entry points**
Find: `manage.py`, `app.py`, `main.py`, `index.js`, `main.go`, `Program.cs`, `Rakefile`, `artisan`, `bin/`, `cmd/`, `src/main*`
Read the first 30 lines of any found. Understand what starts the app and how.

**E — README**
Read `README.md` / `README.rst` / `README.txt` (first 60 lines). Extract a project description.

**F — Test setup**
Find test directories (`tests/`, `test/`, `spec/`, `__tests__/`). Are there tests? What framework?

---

## Step 3 — Code structure sweep (parallel analyst agents)

Spawn one analyst agent per major code directory (up to 4 in parallel). Each agent:
- Lists files in the directory
- Reads key files (models, views, controllers, routes, services — whatever fits the stack)
- Writes `shmorch/state/analysis-<dirname>-discover.md` with:
  - What this module does
  - Key classes / functions / routes
  - Notable patterns or smells
  - External dependencies it uses
  - [CRUFT] anything clearly dead or unused
  - [BLOCKER] anything broken or obviously outdated

Agents read only — never modify files.

---

## Step 4 — Synthesize

After all parallel work completes:

**Write `shmorch/state/context.md`** — fill in every section with real findings:
- Project name and what it does (from README + entry points)
- Tech stack summary (high-level, e.g. "Python 2 / Django / SQLite")
- Confirm existing codebase with list of key directories
- Leave Preferences and Never Do as `<!-- fill in -->` — user must set those

**Write `shmorch/state/stack.md`** — fill in every section with real findings:
- Runtime: what version, what pins it
- Key dependencies: top 8–12 packages with versions and purpose
- External constraints: hosting, API versions, anything that limits upgrades
- Best practice notes: 1–2 bullets per major framework component
- Leave Upgrade Opportunities empty for now

**Update `shmorch/state/session.md`**:
```
## Latest Session
Discovery completed on DATE.
Codebase analyzed: [list of dirs scanned].
context.md and stack.md filled in — review before first session.
```

---

## Step 5 — Stamp completion

```bash
bash shmorch/tools/timelog.sh "PHASE" "discover: complete"
```

---

## Step 6 — Report and hand off

Print a brief summary:
- What the project does (1–2 sentences)
- Stack detected
- Any [BLOCKER] or [CRUFT] flags worth knowing about upfront
- Which state files were written

Then ask: **"Want to review what I found, or jump straight into working on something?"**

If the user wants to review: walk through `state/context.md` and `state/stack.md` together, let them correct anything.

If the user wants to work: transition directly to the `go` flow (read `commands/go.md` and continue from Step 4 onward — skip re-reading context/stack since we just wrote them).
