↑ [code-styleguides/index.md](index.md)

# Code Style Guide: JavaScript

We follow the [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html)
as our primary reference, drawing from [Airbnb's guide](https://github.com/airbnb/javascript)
for areas Google leaves under-specified (error handling, performance, private members).
Where they conflict, Google wins. Use ESLint to automate enforcement.

---

## 1. Files

- **Naming:** All lowercase, with underscores (`_`) or dashes (`-`). Extension must be `.js`.
- **Encoding:** UTF-8.
- **Whitespace:** Spaces only — tabs are forbidden. No trailing whitespace.

---

## 2. Modules

- New files should be ES modules (`import`/`export`).
- **Named exports only** (`export {MyClass};`) — default exports make refactoring and
  static analysis harder because import names are unconstrained.
- **No line-wrapped imports** — keep each import on one line for scannability.
- **Include `.js` extension** in import paths — required for native ES module resolution.
- **All imports at the top** of the file, before any other code.

---

## 3. Formatting

- **Braces:** Required for all control structures (`if`, `for`, `while`, etc.), even
  single-statement blocks. Use K&R / "Egyptian bracket" style (opening brace on same line).
- **Indentation:** 2 spaces per level.
- **Continuation lines:** Indent at least +4 spaces so wrapped content is visually distinct
  from the next block level.
- **Semicolons:** Every statement must end with one. Do not rely on Automatic Semicolon
  Insertion (ASI) — ASI rules are subtle and can produce silent bugs.
- **Line length:** Max 120 characters (per general.md).
- **Blank lines:** Single blank line between methods. No blank lines at the start/end of
  a block.

---

## 4. Naming

| Thing | Convention | Example |
| --- | --- | --- |
| Classes | `UpperCamelCase` | `OrderProcessor` |
| Functions & methods | `lowerCamelCase` | `cancelOrder()` |
| Variables & fields | `lowerCamelCase` | `orderId` |
| Top-level constants | `CONSTANT_CASE` | `MAX_RETRIES` |
| Private members | Prefix with `_` | `_internalState` |

Private `_` prefix is a convention, not enforcement — it signals intent to callers.

---

## 5. Language Features

- **`const` / `let` / no `var`:** Use `const` by default; `let` only when reassignment is
  needed. `var` is forbidden — its function-scoped hoisting behavior is a consistent source
  of bugs.
- **Arrow functions:** Prefer for nested/anonymous functions. They lexically bind `this`,
  eliminating a common class of callback bugs.
- **`this`:** Only use in class constructors, methods, or arrow functions defined within
  them. Using `this` outside that context is almost always a mistake.
- **Equality:** Always use `===` / `!==`. Loose equality (`==`) has non-obvious coercion
  rules that cause hard-to-find bugs.
- **String literals:** Single quotes (`'`). Template literals (`` ` ``) for multi-line
  strings or interpolation. Double quotes for JSX attributes.
- **Destructuring, spread, rest:** Use where they improve readability — don't force them.
- **`for-of`** for iterating arrays. `for-in` only for plain dict-style objects (it
  iterates inherited properties, which surprises people on arrays).
- **Array/Object literals:** Use trailing commas — they produce cleaner diffs. Do not
  use the `Array` or `Object` constructors; literals are clearer and avoid subtle pitfalls.
- **Classes:** Do not use JS getter/setter properties (`get name()`) — provide ordinary
  methods instead. Getters look like field access but can execute arbitrary code, which
  confuses readers.

---

## 6. Disallowed

- `with` — alters scope in ways that make code impossible to reason about statically.
- `eval()` or `Function(...string)` — arbitrary string execution is a security risk and
  prevents optimization.
- Modifying built-in prototypes (`Array.prototype.foo = ...`) — breaks assumptions made
  by libraries and future JS engines.

---

## 7. Comments & JSDoc

- JSDoc on all exported classes, fields, and public methods. Use `@param`, `@return`,
  `@override`, `@deprecated`. Type annotations in braces: `/** @param {string} name */`.
- Inline comments (`//`) for non-obvious logic, workarounds, and intent.
- `// TODO:` for deferred work. `// FIXME:` for known issues that need fixing.

---

## 8. Error Handling

- Use `try...catch` for async operations — unhandled promise rejections fail silently in
  some environments.
- Define custom error classes for domain-specific errors so callers can distinguish them
  with `instanceof`.

---

## 9. Performance

- Batch DOM reads and writes — interleaving them causes forced reflows.
- Debounce or throttle high-frequency event listeners (scroll, resize, input).
- Avoid unnecessary re-renders in UI frameworks; profile before optimizing.
