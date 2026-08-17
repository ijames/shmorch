↑ [code-styleguides/index.md](index.md)

# Code Style Guide: General

## Naming Conventions

- **Files/Folders:** `kebab-case` for URLs/paths, `PascalCase` for classes
- **Variables/Functions:** language-idiomatic case (see the per-stack guide for this project's convention)
- **Classes/Types:** `PascalCase`
- **Constants:** `UPPER_SNAKE_CASE`

## Formatting

- **Indentation:** language-idiomatic (see the per-stack guide)
- **Line Length:** Max 120 characters (overrides the 100 in the JS guide)
- **Braces:** K&R style

## Comments

- Explain *why*, not *what*
- `// TODO:` and `// FIXME:` for deferred work

## Principles

- **DRY / KISS / YAGNI** — avoid premature abstraction; three similar lines beats a helper used once
- **Small footprint** — new order types should not require changes to unrelated code paths
- **Readability over cleverness**
