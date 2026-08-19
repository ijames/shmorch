### Self-Improve Proposals — 2026-08-10 | Project: treeclusion

#### Proposal 1: Strip MoBoS example content out of the skill's own templates
**Pattern:** Contamination from an unrelated project ("MoBoS", a PHP/trading codebase) keeps
appearing inside treeclusion's `.shmorch/`- and `docs/`-seeded files, and it isn't
user-authored — it's baked into the shmorch skill's `templates/` tree and gets copied
verbatim by `init.md` Step 3 into every new project.

**Frequency:** One cleanup commit (`5b84bb2`, PR #41, 2026-08-10) had to strip MoBoS content
out of three separate locations in this project in a single pass:
- `.shmorch/agents/roles/README.md` — "Domain knowledge — MoBoS" example section (PHP service
  layer paths, PHPUnit, "Biz, Order, Market, Trader, Account")
- `docs/development/guides/index.md` — "Operational — task-oriented docs for deploying,
  configuring, and contributing to **MoBoS**", including MoBoS's actual deploy hosts
  (`trentmo`, `mobos`, `jaws`, `mobaws`) and TOML config paths
- `docs/technology/development/code-styleguides/general.md` and `code-styleguides/index.md` —
  "Coding standards for all languages used in **MoBoS**", PHP `snake_case`/`trigger_error()`
  conventions, and a MoBoS-specific spelling rule ("canceled" not "cancelled")

Verified the root cause is still live: `templates/.shmorch/agents/roles/README.md` and
`templates/docs/technology/development/code-styleguides/{index.md,general.md}` in the skill
directory itself still contain this exact MoBoS content today. Any project that runs `init`
or `sync` from this point forward will re-inherit it, exactly as treeclusion did.

**File:** `/Users/james/.claude/skills/shmorch/templates/.shmorch/agents/roles/README.md`,
`/Users/james/.claude/skills/shmorch/templates/docs/technology/development/code-styleguides/index.md`,
`/Users/james/.claude/skills/shmorch/templates/docs/technology/development/code-styleguides/general.md`

**Change:**
- In `roles/README.md`: replace the "## Domain knowledge — MoBoS" example block with a
  domain-neutral placeholder (e.g. a generic "acme-web" or `<your-service-layer-path>`
  stand-in) that demonstrates the override pattern without naming a real prior project.
- In `code-styleguides/index.md`: change "Coding standards for all languages used in MoBoS"
  to "Coding standards for all languages used in this project." Drop or genericize the
  `php-protocols.md` row if PHP isn't a template-default stack (it isn't referenced by
  `init.md`'s stack-detection list handling — confirm and either keep it generic or gate it
  the same way `<stack>.md` files are already gated per Step 3's stack-filter exception).
- In `code-styleguides/general.md`: remove the PHP-specific naming/formatting rules
  (`snake_case (PHP)`, `4 spaces (PHP)`, `trigger_error()`) and the MoBoS-specific spelling
  rule, leaving only genuinely language-agnostic guidance, consistent with the file's own
  stated scope ("Language-agnostic style rules").

**Improvement:** Every future `init`/`sync` stops seeding a brand-new project with another
project's domain content, deploy topology, and naming conventions — removing the need for a
manual contamination-sweep session (this cost a dedicated PR here) on every fresh project.

---

#### Proposal 2: Flag stale taxonomy wording during docs-taxonomy backfill, not just mechanical path moves
**Pattern:** `tools/backfill-docs-taxonomy.sh` does `git mv` on old-taxonomy paths and lists a
fixed `JUDGMENT` array of files needing manual review, but it never checks the *content* of
moved (or existing) files for stale terminology referencing the old taxonomy
(`docs/state/`, `to_review/`, "Inbox for Shmorch"). That check currently only happens if a
human/agent notices it later, file by file.

**Frequency:** Found twice in this project, independent of the JUDGMENT list:
- `docs/inbox/index.md` (2026-08-10) — still had `# To Review`, "Inbox for Shmorch" phrasing,
  and a `docs/state/` reference; discovered and fixed ad hoc, not flagged by any tool.
- `docs/inbox/docs-taxonomy-backfill.md` (written this session as a result) documents a fresh
  grep turning up **9 more files** with the same stale wording, still unfixed as of today:
  `docs/technology/development/github-source-guide.md`,
  `docs/technology/architecture/domains.md`, `docs/product/cognitive-architecture.md`,
  `docs/project/schedule/index.md`, `docs/project/schedule/README.md`, and four track
  `index.md` files.

This is the same underlying gap surfacing twice: the mechanical mapping step in
`backfill-docs-taxonomy.sh` renames paths correctly but has no companion step that greps
*content* for the old vocabulary, so stale wording silently survives the "backfill" and is
only found by manual sweeps months later.

**File:** `/Users/james/.claude/skills/shmorch/tools/backfill-docs-taxonomy.sh`

**Change:** After the mechanical `MAPPING` loop and before printing the `JUDGMENT` report,
add a repo-wide content grep for the retired taxonomy terms (`docs/state/`, `docs/to_review`,
`to_review/`, "Inbox for Shmorch", `docs/architecture/`, `docs/development/` as bare path
references) across all of `docs/`, and append any hits to the printed report under a new
"STALE WORDING — review prose" section (distinct from the existing per-file `JUDGMENT` list,
since these are prose mentions inside files that already got the mechanical move, not files
needing a structural decision).

**Improvement:** The next taxonomy-shaped rename ships with an automated content check instead
of relying on a developer noticing stale wording during an unrelated session months later —
closing the same gap that produced this session's ad hoc inbox item.

### Already addressed
- **"Fix contamination locally even if it matches the skill template"** — already resolved as
  a working rule via `feedback_template_contamination_always_local_fix` (developer correction
  during this session, 2026-08-10): any MoBoS-style content found inside a project's own
  `.shmorch/`/`docs/` counts as local contamination to fix immediately, regardless of origin.
  Proposal 1 above is the complementary upstream half explicitly called for by that same
  memory note ("also flag/PR the skill template itself... the two fixes are not substitutes
  for each other, do both") — not a re-proposal of the already-settled local-fix rule.
- **`stop.sh` wrap-reminder grep never matching real `plan.md` output** — fixed 2026-07-24,
  shipped as shmorch#68 (see `docs/project/session.md`, 2026-07-24 entry: "1 changes applied
  (fixed `stop.sh`'s wrap-reminder grep... see shmorch#68)"). No further evidence of recurrence
  in later sessions.

### No-action observations
- Settings/prefs panel work: scoped into a full feature-flag registry design during the
  2026-07-25 session but not started; only one occurrence so far, next session's stated
  likely starting point per `docs/project/session.md`. Not a pattern yet — recheck next
  self-improve pass if it stalls again without being picked up.
- `docs/development/` vs. canonical taxonomy scope question (raised 2026-07-24, "needs a
  call: fold into `docs/technology/development`, or log as project-specific") appears
  resolved by the 2026-08-10 taxonomy work (old `docs/development/` content is gone — see
  Proposal 1 evidence, `docs/development/guides/index.md` was deleted as contamination rather
  than migrated). One occurrence, now moot — no action needed.
- Repeated `SESSION_START` → `SESSION_END` pairs seconds apart in `timelog.md` (e.g.
  2026-07-21 20:21:17→20:21:23, 2026-07-25 21:47:56→21:48:48, 2026-07-26 00:20:56→00:21:04),
  each auto-closed by the stop hook, with substantial work described only in the `SESSION_END`
  detail. Consistent with the stop-hook firing on each agent turn boundary rather than a true
  session boundary — no explicit developer complaint about this in the evidence, so treated as
  expected hook behavior, not friction. Worth re-examining only if a future session flags it
  as confusing.
