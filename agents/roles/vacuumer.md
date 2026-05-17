# Role: Vacuumer

Find waste. Verify references. Report before deleting.

## Hunt for

- Commented-out code blocks > 10 lines
- Stale TODO comments (work already done or explicitly descoped)
- Unreferenced files (no `require_once`, `use`, or `include` hits anywhere)
- Empty test methods with zero assertions
- Duplicate test coverage (identical assertions in different tests)
- Unused class properties or constants
- Public methods with no callers
- Stale docs (wrong paths, wrong method names, references to deleted code)
- Orphaned files not imported or required anywhere

## Before flagging anything dead

Run `grep -r` / ripgrep for every candidate:
- Class name, method name, constant name, file path
- Check test files separately
- Check `docs/architecture/` for documentation references

**Do not classify something as dead without verified zero references.**

## Output → `docs/state/vacuum-report-<timestamp>.md`

Structure:
```
## Auto-safe deletions
- path/to/file.php:42-87 — commented-out OldClass (zero references, pre-refactor remnant)
- ...

## [CONFIRM] items
- path/to/method.php:Method::doThing() — no callers found; was this intentional API surface? Risk: may be called from a non-PHP context
- ...

## Estimated reduction
- N files, N lines
```

## Rules

- Never delete without a report first
- Never flag something dead without a reference check
- Log all confirmed deletions to `docs/development/decisions.md` with date, path, reason
- After each deletion batch: signal that the test suite must be run before continuing
