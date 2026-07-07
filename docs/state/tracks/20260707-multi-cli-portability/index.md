↑ [Shmorch Plan](../../plan.md)
→ [workflows/init.md](../../../../workflows/init.md) · [shmorch-core.md](../../../../shmorch-core.md) · new `core/portability.md` (proposed)

# Track: Multi-CLI portability (omp / Codex / Cursor, not just Claude Code)

**Status:** Active
**Started:** 2026-07-07
**Domain:** Init & templates / runtime coupling

## Why

Shmorch is authored as a Claude Code skill and hardcodes Claude Code everywhere:
the skill install path (`~/.claude/skills/shmorch/`), the `CLAUDE.md` auto-load
convention, the `Agent` subagent tool, shell-script hooks in `.claude/`, the
`/shmorch` slash-command surface, and Claude-only affordances (`Esc Esc`,
`/rewind`, `CronCreate`). The goal is to make the skill and the files it seeds into
a project (**the repo parts**) load and run under other agent CLIs — primarily
**omp** (Oh My Pi), and by extension Codex / Cursor / opencode, which read
`AGENTS.md`.

This track is the review of what couples shmorch to Claude Code and what must be
abstracted, plus the concrete fixes already applied for the context-file chain.

## What changes

- `workflows/init.md` — generate the portable `AGENTS.md`-first context chain (done).
- `templates/.shmorch/AGENTS.md` — carry the full project-override block (done).
- Downstream callers repointed from the `.shmorch/CLAUDE.md` shim to the
  `.shmorch/AGENTS.md` content file (done).
- Proposed: `core/portability.md` doctrine, a skill-home indirection, and per-CLI
  adapters for the runtime-interaction layer (roadmap below).

---

## Findings

### 1. How other CLIs load context and skills (verified against `omp://` docs)

Verified from `omp://context-files.md`, `omp://skills.md`, `omp://hooks.md`:

- **omp resolves `@`-imports** in context files — recursive to 5 hops, `~/`
  expansion, relative-to-importing-file, cycles skipped, missing target leaves the
  literal `@token`. → the shmorch import chain *mechanism* is portable.
- **omp auto-loads standalone `AGENTS.md`** (`agents-md` provider, walking up to
  the repo root) **but ignores any file whose parent directory starts with `.`**.
  → `.shmorch/AGENTS.md` is **never auto-discovered**; a **root** `AGENTS.md` is.
- **omp does not auto-load a repo-root `CLAUDE.md`.** Its `claude` provider only
  reads `<cwd>/.claude/CLAUDE.md` and `~/.claude/CLAUDE.md`. → the root `CLAUDE.md`
  that `init` writes is invisible to omp.
- **omp discovers Claude skills at `~/.claude/skills/`** via the `claude` provider
  (priority 80, gated by `enableClaudeUser`). → the skill itself is discoverable by
  omp *as long as it lives at the Claude path*; all the hardcoded
  `@~/.claude/skills/shmorch/…` imports and internal self-references then resolve.
- **omp skill invocation** is `/skill:<name> [args]` (injects `SKILL.md` body +
  `User: <args>`), **not** `$ARGUMENTS`. Frontmatter `user-invocable` / `allowed-tools`
  are unknown keys (preserved, ignored).
- **omp hooks are TS factory modules** (`.omp/hooks/*.ts`, `pi.on(...)`), a
  completely different mechanism from Claude's `.claude/settings.json` + shell hooks.
  The shell safety hooks do not fire under omp.

**Thesis:** with the skill living at `~/.claude/skills/shmorch/`, omp already
discovers the skill and resolves the whole `@`-import chain. The *only* missing
piece for project-context loading was that `init` wrote a root `CLAUDE.md`
(omp-invisible) and no root `AGENTS.md`. That is now fixed. The remaining gaps are
the runtime-interaction layer (invocation, subagents, hooks, checkpoints).

### 2. The CLAUDE.md → AGENTS.md chain — was half-migrated; now fixed

Two contradictory patterns coexisted:

- **Templates + `shmorch-core.md`** used the portable chain: root → `.shmorch/CLAUDE.md`
  (`@AGENTS.md`) → `.shmorch/AGENTS.md` → `shmorch-core.md`.
- **`init.md` Step 4 was stale**: it wrote `.shmorch/CLAUDE.md` with the project
  overrides *inline*, importing `shmorch-core.md` directly and **never creating
  `.shmorch/AGENTS.md`**. `templates/.shmorch/AGENTS.md` was also thinner than the
  overrides `init` inlined (no Permission Matrix / Branching Discipline).

**Applied fix (this track):**

- `init` Step 4 now writes `.shmorch/AGENTS.md` (skill-core import + full project
  overrides) as the single source of truth, and `.shmorch/CLAUDE.md` as a thin
  `@AGENTS.md` shim.
- `init` Step 4 **stamps the real skill path** for the `@` import (defaulting to
  `~/.claude/skills/shmorch/shmorch-core.md`) so it resolves wherever the skill is
  installed.
- `init` Step 5 now writes **both** root `AGENTS.md` (`@.shmorch/AGENTS.md`, loaded
  by omp/Codex/Cursor) and root `CLAUDE.md` (`@.shmorch/CLAUDE.md`, loaded by
  Claude Code).
- `templates/.shmorch/AGENTS.md` updated to carry the full override block.
- Callers repointed from the shim to the content file: `go.md` (merge strategy),
  `build.md` (test-command pointer), `commit.md` + `tools/checkpoint.sh` (state
  commit group), `self-improve.md` (project-local target), `auto-update.md` (skip /
  extract targets), `wrap.md` (Current State now written to the shared
  `.shmorch/AGENTS.md`, not the omp-invisible root `CLAUDE.md`).

Verified: reconstructing the generated files and resolving with omp's `@`-import
rules, **both** root `AGENTS.md` and root `CLAUDE.md` expand to include
`shmorch-core.md` and the project overrides.

### 3. Coupling inventory — what else must be made leverageable

Severity: **P0** blocks omp use · **P1** degrades gracefully / manual workaround ·
**P2** cosmetic or doc.

| # | Coupling | Where | Sev | Recommendation |
|---|---|---|---|---|
| A | **Skill home hardcoded** `~/.claude/skills/shmorch/` in ~all workflow reads, tool calls, role resolution, `@` imports | `shmorch-core.md`, `workflows/*`, `agents/**`, `core/override.md`, `commands/*`, `tools`, `docs/*` | P0 | Introduce a single indirection (`$SHMORCH_HOME` / `skill://shmorch`) resolved once; OR canonicalize on `~/.claude/skills/shmorch/` and **document that omp users install/symlink there** (omp's `claude` provider reads it). The symlink is the 1-line unlock today; the env indirection is the clean long-term fix. |
| B | Root context files | `init.md` | P0 | **Fixed** — root `AGENTS.md` + root `CLAUDE.md` both written. |
| C | `.shmorch/AGENTS.md` as source of truth | `init.md`, templates, callers | P0 | **Fixed.** |
| D | **Slash-command dispatch via `$ARGUMENTS`** | `SKILL.md` | P1 | omp passes args as `User: <args>` via `/skill:shmorch <cmd>`. Make `SKILL.md` dispatch read the first word of the trailing user directive generically ("first word of the args, however the CLI delivers them"), not literally `$ARGUMENTS`. |
| E | **Subagent protocol = Claude `Agent` tool** + `SendMessage` + model names `haiku`/`sonnet` | `agents/TASK-PROTOCOL.md`, `agents/orchestrator.md`, `shmorch-core.md` cost discipline | P1 | Abstract to "your CLI's subagent/task tool." omp = `task` tool (named agents: explore/plan/reviewer/task/sonic) + `irc` for messaging + model tiers `smol`/`default`/`slow`. Add a CLI-neutral mapping table; stop hardcoding `haiku`/`sonnet`. |
| F | **Shell safety hooks** (`pre-tool.sh` blocks `rm -rf`/force-push; `session-start.sh`; `stop.sh`) via `.claude/settings.json` | `templates/.claude/**`, skill `.claude/settings.json` | P1 | Claude-only mechanism. Ship an omp-native equivalent as a TS hook (`.omp/hooks/pre/*.ts` using `pi.on("tool_call", …)`), OR document that omp's own approval mode covers it. Session-start context injection has no omp shell-hook analog — see H. |
| G | **`SessionStart` "ask go/resume/nothing"** relies on Claude's session-start event | `shmorch-core.md` §"Session Start" | P1 | omp has `session_start` (TS hook) but the markdown skill can't bind it. Under omp the ask-first behavior triggers on first user turn / when the skill is invoked, not automatically. Document the per-CLI trigger; optionally ship the omp TS hook. |
| H | **Checkpoints** `Esc Esc` / `/rewind` (30-day restore) | `shmorch-core.md`, `commands/help.md`, `shmorch.sh`, `session-start.sh` | P2 | omp has `rewind`/`checkpoint` tools with different UX. Generalize copy to "your CLI's checkpoint/rewind" and keep `/shmorch checkpoint` (git-based, already CLI-neutral). |
| I | **Scheduler** `CronCreate/CronList/CronDelete` | `docs/architecture/scheduler-integration.md` | P2 | Claude-only. Note omp has no in-REPL cron; point at external/system cron or omp equivalents. Doc-only. |
| J | **Launcher** `shmorch.sh` runs `claude --dangerously-skip-permissions`, sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `shmorch.sh`, `templates/shmorch.sh`, `help.md` | P1 | Make launcher pick the CLI (arg/env), or ship `shmorch.sh` (claude) + document `omp` invocation. Drop Claude-only env when launching omp. |
| K | **MCP tool naming** `mcp__zulipchat__…` | `shmorch-core.md` §Communication | P2 | Claude MCP naming; omp uses `mcp://`. Phrase generically ("your CLI's MCP tools for the comms server"). |
| L | **Memory paths** `~/.claude/projects/.../memory/` | `core/documentation.md`, `research/*` | P2 | Claude-specific external memory. omp has `memory://` + retain/recall. Generalize to "the CLI's external memory." |
| M | **Frontmatter** `allowed-tools: Bash, Read, …` (capitalized Claude tool names), `user-invocable` | `SKILL.md` | P2 | Harmless under omp (unknown keys ignored) but misleading. Keep for Claude; note omp ignores. |
| N | **README framing** "skill for Claude Code" throughout, project-structure diagram shows CLAUDE.md-only | `README.md` | P2 | Rewrite intro + structure to the AGENTS.md-first, multi-CLI model. |

### 4. Roadmap status

- **P0 — skill-home indirection (item A): DONE.** `$SHMORCH_HOME` convention added
  (`core/portability.md`), resolved at session start in `shmorch-core.md`, stamped
  per-machine into `.shmorch/home` by `init`/`sync`. ~120 hardcoded paths across
  workflows/agents/core/commands/tools codemod'd to `$SHMORCH_HOME`; the only
  remaining literals are the resolution-recipe default, the stamped `@`-import
  default, and the Claude `.claude/settings.json` adapter. An omp-only install now
  works — the skill can live anywhere and `.shmorch/home` records where.
- **P1 — runtime-interaction adapters (D, E, F, G, J): DONE.** Generic dispatch in
  `SKILL.md` (+ `sync`/`update` aliases); CLI-neutral subagent protocol in
  `TASK-PROTOCOL.md` + `orchestrator.md` (Agent↔task, tiers not vendor models,
  inline fallback); omp TS safety hook (`templates/.omp/hooks/pre/safety.ts`);
  CLI-selecting launchers; session-start trigger made CLI-neutral. The capability
  adapter matrix in `core/portability.md` maps every affordance across CLIs.
- **P2 — docs/cosmetic (H, I, K, L, M, N): partial.** Checkpoints / MCP-naming /
  model-tier prose generalized in `shmorch-core.md`; the README full rewrite and the
  scheduler + memory-path prose remain open.

---

## Work log

### 2026-07-07

- Reviewed the full skill + repo parts for Claude Code coupling; verified omp's
  context-file / skill / hook mechanics from `omp://` docs.
- Found the CLAUDE.md→AGENTS.md migration half-done (templates yes, `init` no) and
  fixed it: AGENTS.md-first chain, root `AGENTS.md` for omp discovery, real-path
  stamping, template + all downstream callers repointed. VERSION → 20260707.01.
- Verified the generated chain resolves for both CLIs against the real
  `shmorch-core.md` using omp's `@`-import rules.
- Logged the coupling inventory (items A–N) and roadmap above. A–C done; D–N open.

### 2026-07-07 (P0 + P1 implementation)

- Added `core/portability.md` (the `$SHMORCH_HOME` recipe, context-file chain,
  capability adapter matrix, graceful-degradation doctrine); registered in `core/index.md`.
- `shmorch-core.md`: session-start resolves/exports `$SHMORCH_HOME`; all skill-file
  refs use it; checkpoints, MCP naming, model tiers, and the session-start trigger
  made CLI-neutral.
- `init.md`: writes `.shmorch/home`; `.shmorch/AGENTS.md` leads with a plain-text
  bootstrap (for literal-`@` CLIs) before the stamped import; seeds `.omp/hooks/` and
  a root `GEMINI.md`; self-guard uses `$SHMORCH_HOME`.
- `auto-update.md` (= `/shmorch sync`): new Step 2.4 migrates existing repos onto the
  chain (split CLAUDE.md→AGENTS.md, add root AGENTS/GEMINI, seed omp hook, refresh
  launcher + `.shmorch/home`) — this is how the upgrade reaches every repo.
- `SKILL.md`: CLI-agnostic dispatch + `sync`/`update` aliases.
- `TASK-PROTOCOL.md` + `orchestrator.md`: subagent protocol abstracted (Claude
  `Agent`/`SendMessage` ↔ omp `task`/`irc` ↔ inline fallback; tiers not model names).
- New `templates/.omp/hooks/pre/safety.ts`; both launchers CLI-selecting; template
  Claude Stop hook resolves via `.shmorch/home`.
- Codemod: 117 path refs → `$SHMORCH_HOME` across 29 files. VERSION → 20260707.02.
- Verified: all three entry points (Claude / omp-family / Gemini) resolve the full
  chain incl. bootstrap; JSON + 6 shell scripts parse; resolution recipe correct.
- Remaining (P2 follow-up): full README rewrite; scheduler + memory-path prose.

### 2026-07-07 (strict single-source de-dup)

- Enforced the no-duplication invariant: `.shmorch/AGENTS.md` is the sole substance file;
  `.shmorch/CLAUDE.md` and all root files (`AGENTS.md`/`CLAUDE.md`/`GEMINI.md`) are pure shims.
- `auto-update.md` Step 2.4b now handles the **both-full-files** case (e.g. DarkBadge): AGENTS.md
  authoritative, migrate any stray substance from CLAUDE.md into it, then shim CLAUDE.md; Step 2.4c
  reduces root files to shims (migrating substance up into AGENTS.md).
- `init.md` Step 5 writes root files as pure shims (dropped the `# PROJECT_NAME` + content
  placeholder that invited drift); `core/portability.md` states the invariant. VERSION → 20260707.03.
- Verified against DarkBadge's exact two-identical-files state: collapses to one source + shims,
  all three CLI entry points still resolve core + overrides.
