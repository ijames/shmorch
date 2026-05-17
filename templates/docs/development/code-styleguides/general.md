↑ [code-styleguides/index.md](index.md)

# Code Style Guide: General

## Naming Conventions

- **Files/Folders:** `kebab-case` for URLs/paths, `PascalCase` for classes
- **Variables/Functions:** `snake_case` (PHP), `camelCase` (JavaScript)
- **Classes/Types:** `PascalCase`
- **Constants:** `UPPER_SNAKE_CASE`

## Special Cases

- **Spelling:** The order status for an order stopped is `canceled` not `cancelled`. Flag divergence from this in the code.

## Formatting

- **Indentation:** 4 spaces (PHP), 2 spaces (JS/HTML/Twig)
- **Line Length:** Max 120 characters (overrides the 100 in the JS guide)
- **Braces:** K&R style

## Comments

- Explain *why*, not *what*
- Use `trigger_error()` for runtime logging in PHP (not comments)
- `// TODO:` and `// FIXME:` for deferred work

## Principles

- **DRY / KISS / YAGNI** — avoid premature abstraction; three similar lines beats a helper used once
- **Small footprint** — new order types should not require changes to unrelated code paths
- **Readability over cleverness**
