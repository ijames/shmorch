# Testing Strategy

↑ [docs/development/](../)
↔ related: [decisions.md](../decisions.md) § "Testing methodology — Intent Driven Design" (2026-05-07), § "Build methodology: simulation before implementation" (2026-05-08)

---

## Methodology

Intent Driven Design. Behavior is understood from the project corpus — architecture docs, decisions, product goals — not from a separate specification artifact. Tests are the first concrete expression of that understanding.

Build order, no exceptions:

1. Functional / integration tests → **RED**
2. Unit tests → **RED**
3. Code (minimum to go green) → **GREEN**
4. Refactor

Gherkin is frozen at the one existing E2E smoke test. No new `.feature` files.

---

## 4-Layer Backend Model

Applies independently to **API** (`app/api/`) and **Dispatcher** (`app/worker/`).

| Layer | Name | Definition | API status | Dispatcher status |
|---|---|---|---|---|
| L1 | Service exists | Imports cleanly, starts without error | GREEN | GREEN |
| L2 | Instrumentation | Structured logging on every request; identical locally and on Lambda/CloudWatch | not built | not built |
| L3 | Connectivity | `/health` or equivalent round-trip passes | GREEN | not built |
| L4 | Feature complete | All endpoints/jobs specified, all cases tested (happy + error + edge) | not built | not built |

Build order within each layer: functional/integration RED → unit RED → code.

---

## Test Types and Locations

| Type | Runner | Location | What it covers |
|---|---|---|---|
| Component / unit | vitest + React Testing Library | `app/frontend/src/**/*.test.tsx` | UI components in isolation |
| API functional | pytest + FastAPI TestClient | `app/api/tests/` | HTTP contract: status codes, response shape, validation |
| Worker functional | pytest + moto | `app/worker/tests/` | SQS handler: event acceptance, error handling |
| E2E smoke | playwright-bdd | `tests/e2e/` | One scenario: landing page loads |

---

## RED Failure Modes

A RED test must fail for the **right reason**. Acceptable RED failures:

| Situation | Expected failure |
|---|---|
| Route not yet implemented | `404 Not Found` |
| Handler raises `NotImplementedError` | `NotImplementedError` exception |
| Missing import | `ImportError` |

Unacceptable: syntax errors, wrong test setup, bad imports in the test file itself. Fix those before calling a test RED.

---

## Make Targets

```bash
make test              # all suites
make test-unit         # vitest (frontend)
make test-api          # pytest (app/api/)
make test-worker       # pytest (app/worker/)  [FILTER=pattern supported]
make test-e2e          # playwright-bdd
make type-check        # tsc --noEmit
```

---

## Local Mocks

→ [local-mocks.md](./local-mocks.md) — SQS mock setup via moto
