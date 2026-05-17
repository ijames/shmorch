↑ [code-styleguides/index.md](index.md)

# PHP Protocols

> This is an **incremental adoption guide**, not a rewrite mandate. Apply these patterns when writing new code or refactoring a specific method. Do not retrofit existing code you are merely passing through. Leave working legacy code alone unless it is the explicit target of the current task.

---

## Method Naming Conventions

Clear, consistent naming makes it immediately obvious at the call site whether a method goes to an external service or stays local.

| Prefix / Verb | Meaning | Examples |
|---------------|---------|---------|
| `fetch*()` | External read — network round-trip to Schwab or another service | `fetchUpdate()`, `fetchQuote()`, `fetchAccount()`, `fetchBalance()` |
| `submit()`, `cancel()`, `preview()` | External write / action — sends a command to Schwab | existing verbs, unchanged |
| `get*()` | Local computed value or property access — no network | `getFixedOrderString()`, `getDecrementedOrder()` |
| `is*()`, `has*()` | Local boolean state query | `isFilled()`, `isInvalid()`, `hasFilled()` |
| `setPriceAndQuantity()`, `build*()`, `calc*()` | Local mutation or construction | `setPriceAndQuantity()`, `buildOrderQueue()` |

**At the Schwab transport layer** (`Schwab` / `Trader` class), HTTP verbs (`get`, `post`, `delete`) are unchanged — they name the HTTP method, not the business operation.

### Why `fetch` not `get` for external reads?

`get*()` is already the PHP convention for local accessors. Using it for network calls creates ambiguity — you cannot tell from the call site whether `getAccount()` hits Schwab or returns a cached value. `fetch*()` is unambiguous: it always means a network round-trip.

### Adoption

Apply when writing new external-read methods or when refactoring an existing one. Leave untouched methods as-is; add a `[fetch-rename]` TODO if you notice one in passing:

```php
// TODO [fetch-rename]: refreshOrder() → fetchUpdate() when refactoring this method
```

Current renames tracked:
- `Order::refreshOrder()` → `Order::fetchUpdate()`
- `Biz::getAccount()` → `Biz::fetchAccount()`
- `Biz::getQuote()` → `Biz::fetchQuote()`
- `Biz::getBalance()` → `Biz::fetchBalance()`

---

## The Three Cases

Every method has exactly three possible outcomes. New and refactored code should handle all three explicitly.

| Case | What it means | Mechanism |
|---|---|---|
| **Happy path** | Work completed successfully | Return typed value |
| **Domain failure** | Expected, recoverable problem in business logic | Throw domain exception |
| **Infrastructure failure** | Unexpected external system failure | Throw infrastructure exception, wrap original |

---

## Entry Point Error Pattern

Every top-level entry point wraps its entire body in a single `try/catch` that converts unhandled exceptions into user-visible feedback:

**HTML entry points** (execute.php, fu.php, account.php, quote.php, login.php, auth.php, prices.php, cancel_orders.php) — add a flash error and let the page render:

```php
try {
    // ... all page logic
} catch (Exception $e) {
    $flash->add($e->getMessage(), Flash::ERROR);
}
// page render continues — user sees the error inline
```

**API endpoints** (api/abort.php, api/abort_and_cancel.php) — return a JSON error body:

```php
try {
    // ... all endpoint logic
    echo json_encode(['status' => 'ok']);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
```

The `catch (Exception $e)` at this level is intentionally broad — it is a safety net, not a handler. Domain-specific recovery (e.g., marking an order invalid) happens deeper in the stack before the exception ever reaches here.

---

## When to Apply These Guidelines

| Situation | Action |
|---|---|
| Writing a new method | Apply fully |
| Refactoring a method that is the explicit task | Apply fully |
| Touching a method for an unrelated bug fix | Apply only to the lines changed; add a TODO comment for the rest |
| Reading or tracing through legacy code | Do nothing — do not "clean as you go" |
| Calling a legacy method that returns null/false | Wrap the call site locally; do not modify the legacy method |

The goal is a **tide that rises gradually** — each touched method becomes compliant, everything else is undisturbed.

---

## Exception Hierarchy

The live hierarchy in `htdocs/exceptions.php`:

```
AppException extends RuntimeException   ← base for everything; catch-all at top level
├── DomainException                     ← base for all business logic failures
│   ├── AbortException                  ← abort flag detected mid-processing loop
│   ├── ValidationException             ← structured field errors ([field => reason] map); reserved
│   └── OrderParseException             ← defined in order.php; single order failed to parse
└── InfrastructureException             ← base for external system failures (API, network)
```

`DomainException` is PHP's built-in in test contexts; `exceptions.php` skips the declaration when it's already loaded. The hierarchy still works — `AbortException` etc. extend the built-in `DomainException`.

Service-specific exceptions live at the top of the file that throws them. Extend the hierarchy as new exception types are needed — do not create types speculatively.

---

## Structuring Exception Classes

Exceptions are objects. Carry whatever the catch site needs to handle the failure without redoing work.

```php
// Base — thin, no extra payload
class DomainException extends AppException {}

// Validation — carries structured field errors
class ValidationException extends DomainException
{
    public function __construct(
        private readonly array $errors,   // ['field' => 'reason', ...]
        string $message = 'Validation failed',
        ?\Throwable $previous = null
    ) {
        parent::__construct($message, 0, $previous);
    }

    public function getErrors(): array { return $this->errors; }
}

// Infrastructure — always wraps the original throwable
class DatabaseException extends InfrastructureException
{
    public function __construct(string $message, \Throwable $previous)
    {
        parent::__construct($message, 0, $previous);
    }
}
```

`readonly` means the property is set once in the constructor and cannot be changed. Constructor promotion (`private readonly array $errors` in the parameter list) declares and assigns it in one line — no separate property declaration needed.

Always pass `$previous` when wrapping another exception. This preserves the original stack trace through the wrapping chain.

---

## Authoring a New or Refactored Method

```php
function doWork(array $input): ResultType
{
    // 1. Validate first — before any expensive work or persistence
    $errors = validate($input);
    if (!empty($errors)) {
        throw new ValidationException(errors: $errors);
    }

    // 2. Domain logic — throw for known failure states
    $entity = findEntity($input['id']);
    if ($entity === null) {
        throw new NotFoundException(id: $input['id'], resource: 'Order');
    }

    if ($entity->isProcessed()) {
        throw new ConflictException(message: 'Order already processed');
    }

    // 3. Wrap all external calls
    try {
        $result = $this->db->save($entity);
    } catch (\PDOException $e) {
        throw new DatabaseException(message: 'Failed to save order', previous: $e);
    }

    // 4. Return typed value — happy path only
    return $result;
}
```

---

## Calling a Method

```php
try {
    $result = $service->doWork($input);
} catch (ValidationException $e) {
    return response()->errors($e->getErrors());
} catch (NotFoundException $e) {
    return response()->notFound($e->getMessage());
} catch (ConflictException $e) {
    return response()->conflict($e->getMessage());
} catch (DatabaseException $e) {
    $this->logger->error('DB failure', ['exception' => $e, 'previous' => $e->getPrevious()]);
    return response()->serverError();
} catch (AppException $e) {
    $this->logger->warning('Unhandled domain exception', ['exception' => $e]);
    return response()->serverError();
}
```

Catch blocks run top to bottom — most specific first, broadest last. `AppException` at the bottom catches anything in the hierarchy not explicitly handled above.

---

## Wrapping Legacy Call Sites

When new compliant code calls a legacy method that returns `null` or `false`, adapt at the call site without touching the legacy method:

```php
// Legacy method you are not refactoring:
// function findUser(int $id): ?User { ... returns null ... }

// Compliant wrapper at your call site:
$user = $legacyService->findUser($id);
if ($user === null) {
    throw new NotFoundException(id: $id, resource: 'User');
}
```

This keeps the legacy method untouched while making your new code compliant from its boundary inward.

---

## Partial Work and Resume

When a method has distinct phases and earlier phases produce reusable output, carry completed work in the exception so the caller can resume without redoing it.

```php
class PipelineException extends DomainException
{
    public function __construct(
        private readonly array $completedSteps,
        private readonly string $failedStep,
        private readonly array $errors,
        ?\Throwable $previous = null
    ) {
        parent::__construct("Pipeline failed at: {$failedStep}", 0, $previous);
    }

    public function getCompletedSteps(): array { return $this->completedSteps; }
    public function getFailedStep(): string    { return $this->failedStep; }
    public function getErrors(): array         { return $this->errors; }
}
```

Use when retrying the full method would be expensive or have side effects.

---

## Easy Wins — Quick Fixes Worth Doing Opportunistically

These are low-effort, low-risk improvements that are acceptable to apply even when not doing a full refactor of a method:

**Swallowed exceptions** — the single most harmful pattern. If you see it, fix it:
```php
// ❌ before
try { $db->save($e); } catch (\Exception $e) { }

// ✅ after — minimum fix, no hierarchy needed yet
try { $db->save($e); } catch (\Exception $e) {
    $this->logger->error('Save failed', ['exception' => $e]);
    throw $e; // rethrow if you cannot handle it here
}
```

**Raw PDOException bubbling** — wrap it wherever you spot it:
```php
} catch (\PDOException $e) {
    throw new DatabaseException('Save failed', previous: $e);
}
```

**Null return being ignored by callers** — add a TODO at the call site:
```php
$user = $this->repo->findUser($id); // TODO: legacy returns null — wrap in NotFoundException when refactoring this method
```

---

## TODO Comment Convention

When you touch code that should be migrated but is out of scope for the current task, leave a structured TODO:

```php
// TODO [exception-migration]: returns null on failure — convert to NotFoundException when refactoring
// TODO [exception-migration]: throws raw \RuntimeException — replace with DatabaseException when refactoring
// TODO [exception-migration]: swallows PDOException in catch block — needs logging and rethrow
```

The `[exception-migration]` tag makes these greppable across the codebase so the team can track outstanding migration work without it blocking current tasks.

---

## What Not to Do in New or Refactored Code

```php
// ❌ null as a failure signal
function findUser(int $id): ?User { return null; }

// ❌ false as a failure signal
function save(Entity $e): bool { return false; }

// ❌ catching and swallowing
try { $db->save($e); } catch (\Exception $e) { }

// ❌ raw infrastructure exception escaping domain code
// PDOException reaches the controller with no context

// ❌ generic exception
throw new \Exception('something went wrong');

// ❌ mixed success/failure in return value
return ['success' => false, 'error' => 'invalid'];
```

---

## Checklist — New and Refactored Methods Only

- [ ] Returns a single typed value on happy path
- [ ] Validates input before any persistence or external calls
- [ ] Domain failures throw a typed `DomainException` subclass
- [ ] All external calls are wrapped — no raw infrastructure exceptions escape
- [ ] `$previous` is passed when wrapping exceptions
- [ ] Exception payload carries what the catch site needs
- [ ] No null/false returns as failure signals
- [ ] No swallowed exceptions
- [ ] Legacy call sites that return null/false are wrapped locally with a typed throw
- [ ] Out-of-scope legacy code has `[exception-migration]` TODOs where applicable
