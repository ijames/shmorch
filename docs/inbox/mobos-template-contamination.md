# Proposal: strip MoBoS example content out of the skill's own templates

**Source:** self-improve run, 2026-08-10, project `treeclusion`
**Status:** Proposed, developer-approved for filing (not yet applied)

## Pattern

Contamination from an unrelated project ("MoBoS", a PHP/trading codebase) keeps appearing
inside downstream projects' `.shmorch/`- and `docs/`-seeded files, and it isn't
developer-authored — it's baked into the skill's own `templates/` tree and gets copied
verbatim by `init.md` Step 3 into every new project.

## Evidence

One cleanup commit (`5b84bb2`, treeclusion PR #41, 2026-08-10) had to strip MoBoS content
out of three separate locations in that project in a single pass:
- `.shmorch/agents/roles/README.md` — "Domain knowledge — MoBoS" example section (PHP service
  layer paths, PHPUnit, "Biz, Order, Market, Trader, Account")
- `docs/development/guides/index.md` — "Operational — task-oriented docs for deploying,
  configuring, and contributing to **MoBoS**", including MoBoS's actual deploy hosts
  (`trentmo`, `mobos`, `jaws`, `mobaws`) and TOML config paths
- `docs/technology/development/code-styleguides/general.md` and `code-styleguides/index.md` —
  "Coding standards for all languages used in **MoBoS**", PHP `snake_case`/`trigger_error()`
  conventions, and a MoBoS-specific spelling rule ("canceled" not "cancelled")

Root cause confirmed still live in the skill itself:
`templates/.shmorch/agents/roles/README.md` and
`templates/docs/technology/development/code-styleguides/{index.md,general.md}` still contain
this exact MoBoS content today. Any project that runs `init` or `sync` from this point
forward will re-inherit it, exactly as treeclusion did.

## Proposed change

Files:
- `templates/.shmorch/agents/roles/README.md`
- `templates/docs/technology/development/code-styleguides/index.md`
- `templates/docs/technology/development/code-styleguides/general.md`

- In `roles/README.md`: replace the "## Domain knowledge — MoBoS" example block with a
  domain-neutral placeholder (e.g. a generic "acme-web" or `<your-service-layer-path>`
  stand-in) that demonstrates the override pattern without naming a real prior project.
- In `code-styleguides/index.md`: change "Coding standards for all languages used in MoBoS"
  to "Coding standards for all languages used in this project." Drop or genericize the
  `php-protocols.md` row if PHP isn't a template-default stack (confirm against `init.md`'s
  stack-detection list, and either keep it generic or gate it the same way `<stack>.md` files
  are already gated per Step 3's stack-filter exception).
- In `code-styleguides/general.md`: remove the PHP-specific naming/formatting rules
  (`snake_case (PHP)`, `4 spaces (PHP)`, `trigger_error()`) and the MoBoS-specific spelling
  rule, leaving only genuinely language-agnostic guidance, consistent with the file's own
  stated scope ("Language-agnostic style rules").

## Improvement

Every future `init`/`sync` stops seeding a brand-new project with another project's domain
content, deploy topology, and naming conventions — removing the need for a manual
contamination-sweep session (this cost a dedicated PR in treeclusion) on every fresh project.
