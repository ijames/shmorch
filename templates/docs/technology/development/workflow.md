↑ [development/](index.md)

# Project Workflow

## Commit Conventions

```text
type(scope): description

Types: feat, fix, refactor, test, docs
Examples:
  feat(auth): add session expiry check
  fix(api): correct pagination offset
  test(order): add coverage for edge case X
  docs(architecture): update system diagram
```

**Types:**
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change that neither fixes a bug nor adds a feature
- `test` — Adding missing tests
- `docs` — Documentation only

## Task Execution

1. Identify the task in `docs/project/tracks/`
2. Write failing tests first (TDD)
3. Implement to pass tests
4. Verify code coverage against project target
5. Stage and commit with proper message
6. Update track documentation

## Testing

See [testing/](testing/index.md) for how to run the test suite and coverage requirements.

## Code Review Checklist

Before committing:

- [ ] All tests pass
- [ ] Code follows style guides (see [code-styleguides/](code-styleguides/index.md))
- [ ] No security vulnerabilities introduced
- [ ] Works correctly on all target environments
- [ ] Documentation updated if needed
- [ ] Commit message is clear and follows conventions
