# Workflow: Verify (Parity Check)

Confirm that documentation, code, and tests are in sync. Documentation describing realized features is the source of truth — if a feature is documented as existing, tests and code must exist and work. Humans should not be responsible for finding gaps; agents run this check.

## When to use
- After completing a build track (before PR/merge)
- Before `/shmorch wrap` on any day that included new features or scenarios
- Anytime docs are edited without corresponding code changes (or vice versa)
- On demand via `/shmorch verify`

## Inputs
- `features.gherkin` — scenario definitions
- `docs/` — realized-feature descriptions
- `tests/e2e/steps/` — step definitions
- `docs/development/setup.md` — setup commands

## Roles
- None — runs inline

---

## What "parity" means

Three things must stay in lock-step:

| Layer | Source of truth | Verified by |
|---|---|---|
| Acceptance criteria | `features.gherkin` scenarios | Step definitions exist + run |
| Documented features | `docs/` realized-feature descriptions | Scenarios exist in gherkin |
| Implementation | Code files | Tests pass (not just exist) |

**Broken parity examples:**
- A scenario in `features.gherkin` has no step definition → RED (expected) or MISSING (unstarted)
- A feature described in docs as "implemented" has no scenario → documentation lying
- A step definition exists but its implementation raises `NotImplementedError` → acceptable stub; flag if scenario is marked done
- A README describes a `pnpm test` command that doesn't work → broken setup parity

---

## Step 1 — README audit

For each component directory (`app/frontend/`, `app/api/`, `app/worker/`, `tests/e2e/`, and project root):

1. Does a `README.md` exist?
2. Is it project-specific? Flag if it contains: "bootstrapped with create-next-app", "This is the example for", "no test specified", or other generic boilerplate strings.
3. Does it include: a one-line description of the component, run commands, a link to `docs/development/setup.md`?
4. Are the run commands accurate? Spot-check by verifying the referenced files exist (`package.json`, `pyproject.toml`, entry points).

Report: list of READMEs with pass/fail/flag per criterion.

---

## Step 2 — App structure audit

For each component, verify the expected skeleton exists:

| Component | Expected files |
|---|---|
| `app/frontend/` | `package.json`, `src/app/page.tsx`, `src/app/layout.tsx`, `next.config.*` |
| `app/api/` | `pyproject.toml`, `main.py` with a `handler` export |
| `app/worker/` | `pyproject.toml`, `main.py` with a `handler` function |
| `tests/e2e/` | `playwright.config.ts`, `steps/` directory, feature file reference resolvable |
| `infra/` | `template.yaml` |
| `db/` | `schema.sql` |

Missing expected files = structural gap. Report them.

---

## Step 3 — Scenario → step definition parity

1. Parse `features.gherkin` — extract all `Scenario:` and `Scenario Outline:` blocks by feature area.
2. For each scenario, check whether a matching step definition file exists in `tests/e2e/steps/`.
3. Classify each scenario:
   - **GREEN** — step definitions exist and contain non-stub assertions
   - **RED** — step definitions exist but are stubs (no assertions / `throw new Error('not implemented')`)
   - **MISSING** — no step definition file for this scenario

Expected state during a proof sprint: GREEN or RED (not MISSING). MISSING = scenario was written but never even started.

---

## Step 4 — Documentation → scenario parity

1. Scan `docs/` for files that describe features as "implemented", "complete", or "working" — or that use present tense to describe user-facing behavior ("users can browse...", "the score displays...").
2. For each such feature claim, check that at least one scenario in `features.gherkin` covers it.
3. Flag any claim with no corresponding scenario as **undercovered** — docs are ahead of tests.

Conversely: scan `features.gherkin` for any scenario with no corresponding section in any `docs/` file — flag as **undocumented scenario**.

---

## Step 5 — Setup.md accuracy

For each command block in `docs/development/setup.md`:
1. Verify referenced package manager binaries exist (`pnpm`, `uv`, `node`, etc.)
2. Verify referenced config files exist (`package.json`, `pyproject.toml`, `playwright.config.ts`)
3. Verify referenced install commands match actual dependency manifests (e.g. if setup.md says `pnpm install`, `package.json` must exist)
4. Flag any command referencing a non-existent file or path

---

## Step 6 — Write parity report

Write `docs/state/parity-report-<YYYY-MM-DD>.md`:

```markdown
# Parity Report — <date>

## README audit
| Component | Exists | Project-specific | Run commands | Setup link | Notes |
|---|---|---|---|---|---|
...

## Structure gaps
(list missing expected files)

## Scenario coverage
| Scenario | Status | Notes |
|---|---|---|
...

## Docs → test coverage gaps
(list undercovered feature claims)

## Setup.md accuracy
(list broken command references)

## Summary
N issues found. M auto-fixable (generic README boilerplate). K require developer attention.
```

---

## Step 7 — Surface and act

Present the summary to the user. Auto-fixable items (empty test scripts, generic README boilerplate) can be fixed inline with confirmation. Structural gaps and coverage gaps require developer attention — open a `plan.md` item for each unresolved gap.

Never silently pass a parity check that has failures. The point of this workflow is that broken parity is visible.
