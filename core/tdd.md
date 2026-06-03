# TDD Doctrine

## Prime Directive — Intent → Spec → Test → Code

**This rule overrides everything else. It applies to every task, every session, every change — no exceptions.**

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

**For `docs/state/acceptance.md`:**
- Each item carries a creation date: `- [ ] YYYY-MM-DD · criterion text`
- Completed items carry both dates: `- [x] YYYY-MM-DD → YYYY-MM-DD · criterion text`
- Retrospective items (AC written after implementation) are noted: `_(retrospective)_`
- Every item cites its intent source: `← intent-source` (BDD scenario, plan.md item, decision)
- Items without intent sources are interrogated before the AC document is considered valid
- Items are never silently deleted — if descoped, they move to a `## Descoped` section with date and reason

**AC items grow with scope** — new features get new AC items — but each new item must cite where the requirement came from.

---

## Always-Red Rule

**An active project MUST always have red items. All green = done. If everything is green mid-sprint, the tests are behind the work — that is a failure state, not a success.**

"Tests" in this context means the full stack:

| Layer | Red means |
|---|---|
| Intent | Next feature has no spec or scenario yet |
| Spec / BDD | At least one unimplemented scenario exists |
| `docs/state/acceptance.md` | At least one unchecked `- [ ]` item in the MVP sections |
| Unit / integration tests | At least one failing test for the next planned behaviour |
| Manual UX | At least one open UX acceptance criterion |
| Deployment | Not yet live at a public URL |

**`docs/state/acceptance.md` is a first-class test artefact.** Every unchecked `- [ ]` item in the MVP sections counts as a failing test. The project is not done until every MVP box is checked. `/shmorch status` must show the AC red/green split alongside unit test counts.

**How to count AC red items** (stops at the `## Post-MVP` boundary):
```bash
awk '/^## Post-MVP/{exit} /^\- \[ \]/{count++} END{print count+0}' docs/state/acceptance.md
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
