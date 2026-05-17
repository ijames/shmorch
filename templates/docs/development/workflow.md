↑ [development/index.md](index.md)

# Project Workflow

## Commit Conventions

```text
type(scope): description

Types: feat, fix, refactor, test, docs
Examples:
  feat(abort): add AbortFlag::clear() on execute mode startup
  fix(js): rename cancel button to abort, fix status string check
  test(order): add recToString() and newOrderFromRec() coverage
  docs(architecture): update order state machine diagram
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `test` — Adding missing tests
- `docs` — Documentation only

## Task Execution

1. Identify the task in `/docs/tracks/`
2. Write failing tests first (TDD)
3. Implement to pass tests
4. Verify code coverage (>80%)
5. Stage and commit with proper message
6. Update track documentation

## Testing

### Running Tests

```bash
cd htdocs && php ../vendor/bin/phpunit tests/
```

### Requirements

- Write unit tests before implementing functionality
- Target >80% code coverage for new code
- Mock external dependencies
- Test both success and failure cases

### Test Files

Location: `htdocs/tests/`

Follow existing test naming conventions and patterns in the repository.

## Code Review Checklist

Before committing:

- [ ] All tests pass
- [ ] Code follows style guides (see `code-styleguides/`)
- [ ] No security vulnerabilities introduced
- [ ] Works correctly on all target environments
- [ ] Documentation updated if needed
- [ ] Commit message is clear and follows conventions
