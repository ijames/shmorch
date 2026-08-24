---
loads_when: any code change (fix, migration, config, feature) — the No Test No Code prime directive, testing depth ladder (stage + form), temporal propagation, always-red rule, branch roles, AC sync
size: 149 lines
---

# TDD Doctrine

## Prime Directive — Intent → Spec → Test → Code

**This rule overrides everything else. It applies to every task, every session, every change — no exceptions to *whether* there's a test, only to *how much* one costs. See "Testing Depth Ladder" below for what "test" scales to at each project stage.**

```
No scenario  → no feature
No test      → no code
```

The sequence is always:

1. **Intent** — understand what the user actually wants (95% confidence interview)
2. **Spec** — write or confirm the spec; BDD scenarios if behaviour-facing
3. **Tests RED** — write failing tests before touching production code
4. **Code GREEN** — minimum implementation to pass
5. **Refactor** — clean up with tests green

**Hard stops:**
- Never edit production code before tests exist for the change
- Never skip a step because the task seems small or obvious
- Never add tests after the fact to cover code already written — that is not TDD, it is documentation
- If asked to fix a bug: write a failing test that reproduces it first, then fix
- If asked to add a feature: write the scenario/test first, then implement

When caught violating this (by the user or self-review): stop, acknowledge, write the missing tests, then continue. Do not argue that the change was too simple to need tests.

---

## Testing Depth Ladder

"Test" is not one thing. It scales along two independent axes — **project stage** (how
formal does this need to be) and **form** (what kind of check fits the layer being
touched). Pick the rung that fits; don't default to the heaviest form out of habit, and
don't skip testing entirely just because the heaviest form feels like overkill.

### Stage axis — how much a project's testing formality earns

Reuses the project's `stage` field verbatim (`shmorch-core.md` § Project Stage,
`context.md`) — the same stage `web_spec_compliance.md` and `observability.md` key off
of. That table already sets the Test gate per stage; the row below just says what *form*
of test satisfies each gate:

| Stage | Test gate (from § Project Stage) | Form this satisfies it with |
|---|---|---|
| `R&D` | None required | Checklist, if anything — the point is to learn fast. Don't build a harness for code that may be thrown away tomorrow. |
| `proof-sprint` | Functional/integration RED before unit RED before code | High-level assertions covering the core paths; checklist for the rest. |
| `productionization` | Full coverage | Full TDD/BDD per the Prime Directive above — RED before code, AC-synced, always-red rule applies. |
| `maintenance` | Regression suite passes | Full TDD/BDD, plus the deployment/AC rigor in "Always-Red Rule" and "Acceptance Criteria Document" below — nothing is optional at this stage. |

A project's testing posture follows `stage` as it changes, not ahead of it. Don't
pre-build `maintenance`-grade test rigor for an `R&D` spike that hasn't earned
`proof-sprint` yet — that's the inverse failure of skipping tests, and just as costly.
When `stage` advances, retrofit tests for what's already there rather than leaving it
permanently under-tested for its current stage.

### Form axis — what kind of check fits

Lightest to heaviest; each is a valid "test" at the right stage, not a lesser substitute
for the one above it:

1. **Checklist** — a manual or semi-automated list of "does X work," checked off by hand.
   Right for `R&D`, or for UX/manual-verification items even in mature projects (see "UX
   criteria" in Acceptance Criteria below).
2. **High-level assertions** — a small block of code asserting the core behavior end to
   end, no framework ceremony. Right for `proof-sprint` and for scripts/tools too small to
   warrant a full suite.
3. **TDD / BDD** — full RED→GREEN cycle, scenario-first for behavior-facing work. Right
   for `productionization`/`maintenance`, per the Prime Directive.

Which of TDD vs. BDD (or both) applies depends on layer, not stage: BDD scenarios for
user-facing behavior (frontend, API contracts, anything a spec can describe from outside),
unit/integration TDD for backend logic, algorithms, and anything with no meaningful
outside-in behavior to script.

**"Frontend → BDD" is not a blanket rule — Gherkin has real overhead.** TDD-with-mocks
(unit tests, stubbed API responses, component-level assertions) is cheap and straightforward
on every surface, frontend included. Gherkin/Cucumber is a different cost: it needs a
step-definition framework wired to a real or headless browser, and that harness is itself
nontrivial code to write and maintain — not free the way a plain assertion block is. Before
reaching for it, split what's actually being tested:

- **User action / behavior** ("clicking X navigates to Y," "submitting the form shows an
  error") — the right fit for Gherkin, because the scenario describes intent that survives
  a redesign. Low thrash.
- **Visual positioning / layout** ("the button is 12px from the edge," "the card grid is
  3-wide above 1024px") — a poor fit for Gherkin scenarios. This is closer to a snapshot/
  visual-regression check than a behavior spec, and during rapid design iteration these
  assertions **will** thrash — the scenario file itself becomes churn, not signal. Prefer
  a lighter visual-diff or manual-checklist item here until layout has actually stabilized.

Treating these as the same kind of test is what makes the BDD-for-UI decision feel harder
than it is. They're not the same test, and only one of them wants Gherkin. Adopt Gherkin
per-surface once user-action behavior is stable enough to be worth scripting — not as a
day-one default just because the layer is "frontend."

**A Makefile (or equivalent task runner) always exists**, regardless of stage or form —
`make test`, `make check`, whatever the project's language convention is — so the testing
posture that does exist is one command away, not tribal knowledge. This is the one thing
that doesn't scale down with stage.

---

## Temporal Propagation — Bottom-Up Inception Is Real

**The source of truth is top-down. The inception of truth is often bottom-up. Both are valid; only one direction gets tracked by default.**

In practice — especially with AI-assisted development — code frequently exists before tests, tests before AC, and AC before stated intent. This is not a failure. It is normal. The failure is letting bottom-up artifacts linger without propagating them upward.

**Timestamps are provenance.** Every artifact has a creation date. The ordering reveals the actual inception path:

| Ordering | Meaning | Required action |
|---|---|---|
| Intent → Spec → AC → Test → Code | Prospective (correct flow) | None |
| Code exists, no test | Bottom-up inception | Write test, then interrogate intent |
| Test exists, no AC item | Test without contract | Add AC item, verify it reflects true intent |
| AC item exists, no intent source | Wish, not requirement | Cite intent source or remove |
| AC item checked off, implementation predated it | Retrospective AC | Mark as retrospective; note approximate impl date |

**Propagation is the correct response.** When any artifact lacks upstream coverage:
1. **Detect** — code with no test, test with no AC, AC with no intent source
2. **Interrogate** — "Is this what was intended? Is it still current? Is it correct?"
3. **Propagate** — write the missing upstream artifact and link it to its source
4. **Timestamp** — the propagation item's date reveals it was bubbled up, not driven from intent

**A bottom-up item without interrogation is a liability.** It might be wrong, stale, or an accidental artefact with no backing intent.

**For `docs/project/acceptance.md`:**
- Each item carries a creation date: `- [ ] YYYY-MM-DD · criterion text`
- Completed items carry both dates: `- [x] YYYY-MM-DD → YYYY-MM-DD · criterion text`
- Retrospective items (AC written after implementation) are noted: `_(retrospective)_`
- Every item cites its intent source: `← intent-source` (BDD scenario, plan/ item, decision)
- Items without intent sources are interrogated before the AC document is considered valid
- Items are never silently deleted — if descoped, they move to a `## Descoped` section with date and reason

**AC items grow with scope** — new features get new AC items — but each new item must cite where the requirement came from.

---

## Always-Red Rule

**An active project at `productionization`/`maintenance` stage (see Testing Depth Ladder above) MUST always have red items. All green = done. If everything is green mid-sprint, the tests are behind the work — that is a failure state, not a success.** `R&D`-stage projects are exempt — they may have no tests at all, which isn't a red/green state, it's off the ladder entirely.

"Tests" in this context means the full stack:

| Layer | Red means |
|---|---|
| Intent | Next feature has no spec or scenario yet |
| Spec / BDD | At least one unimplemented scenario exists |
| `docs/project/acceptance.md` | At least one unchecked `- [ ]` item in the MVP sections |
| Unit / integration tests | At least one failing test for the next planned behaviour |
| Manual UX | At least one open UX acceptance criterion |
| Deployment | Not yet live at a public URL |

**`docs/project/acceptance.md` is a first-class test artefact.** Every unchecked `- [ ]` item in the MVP sections counts as a failing test. The project is not done until every MVP box is checked. `/shmorch status` must show the AC red/green split alongside unit test counts.

**How to count AC red items** (stops at the `## Post-MVP` boundary):
```bash
awk '/^## Post-MVP/{exit} /^\- \[ \]/{count++} END{print count+0}' docs/project/acceptance.md
```

**When the user reports "all tests green":** Ask immediately — are there AC items still unchecked? If yes, the project is not done.

**Never interpret a fully-green test run as project completion during an active sprint.**

### Branching and the Two Reds

The always-red rule and a passing CI gate are not in conflict — they refer to different things.

| Red kind | Lives where | Blocks CI? |
|---|---|---|
| **Product red** — unchecked AC items, unimplemented scenarios | `acceptance.md`, open feature branches | No |
| **Branch red** — failing tests for in-progress work | Feature branch only | Yes — blocks merge |

`main` must always pass CI. The project must always have unfinished work. Both are true because product red lives in the backlog and on feature branches, never on `main`.

**Branch roles:**

| Branch | CI gate | Purpose |
|---|---|---|
| `main` | Always green | Deployable at all times |
| `staging` | Mirrors main + smoke tests | Integration verification |
| `feature/*` | Red during development — by design | Where new work happens |
| `hotfix/*` | Must be green before merge | Off-cycle fixes |

**Feature branch lifecycle:** write failing test → implement → green → PR → merge → delete branch. Never merge red. Never commit aspirational failing tests to `main` — if future work needs signalling, add an AC item to `acceptance.md`.

**AC ↔ test sync:** Every checked AC item must have a passing test on `main`. Every passing test on `main` covering user-facing behaviour must trace to an AC item. Gaps in either direction are caught by `/shmorch vacuum`.

---

## Acceptance Criteria Document

Every project at `proof-sprint` stage or above (see Testing Depth Ladder above) must have `docs/project/acceptance.md`. Create it as part of the spec phase (before code), not after. `R&D`-stage projects may skip it — a checklist in the session notes is enough until the project earns `proof-sprint`.

**Structure:**
```
# Acceptance Criteria — <project name>

## 1 — Functional: <area>
- [ ] <criterion derived from BDD scenario>
- [x] <criterion already met>

## N — Deployment
- [ ] Live at public URL
- [ ] Smoke test passes against production

## Post-MVP (does not block release)
- [ ] <deferred item>
```

**Rules:**
- MVP sections (everything except Post-MVP) must all be `[x]` before release
- Each criterion should be verifiable — either by an automated test, a BDD scenario passing, or explicit manual sign-off
- Criteria map to BDD scenario tags where possible (e.g. `— @browse @smoke`)
- UX criteria (layout, touch targets, readability) are explicit checklist items — not "implied by code working"

**Relationship to BDD:**
- BDD scenarios → acceptance criteria (1:1 or many:1 for related scenarios)
- Passing E2E test = green AC item (automated)
- Passing manual check = green AC item (needs explicit sign-off, not assumed)
- Scenario tagged `@stub` or `@real-pipeline` may require real infrastructure before going green
