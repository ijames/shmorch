# Cross-CLI Portability

Shmorch is authored as a Claude Code skill but is designed to run under any agent
CLI that can read a context file and run a shell — omp (Oh My Pi), Pi, Codex,
Gemini CLI, opencode, Cursor, Antigravity, and Claude Code. The user must be able
to switch CLIs freely inside the same project without re-initializing.

Two rules make this work:

1. **Never hardcode the skill's install path.** Use `$SHMORCH_HOME` (below).
2. **Degrade gracefully.** Every Claude-only affordance has a fallback that works
   with nothing but a context file, a file-read tool, and a shell. When a CLI lacks
   a feature (subagents, hooks, checkpoints), the workflow still completes — the
   orchestrator just does that step inline.

---

## `$SHMORCH_HOME` — the skill's install directory

`$SHMORCH_HOME` is the absolute path to the shmorch skill directory (the folder
containing `SKILL.md`, `shmorch-core.md`, `workflows/`, `core/`, `agents/`,
`tools/`). Every reference to a skill file — whether you `read` it or run it with
`bash` — goes through `$SHMORCH_HOME`, never a literal `~/.claude/skills/shmorch`.

**Resolve once at session start, first hit wins, then export it:**

```bash
SHMORCH_HOME="${SHMORCH_HOME:-}"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$(cat .shmorch/home 2>/dev/null || true)"
[ -n "$SHMORCH_HOME" ] || SHMORCH_HOME="$HOME/.claude/skills/shmorch"
export SHMORCH_HOME
```

1. An existing `$SHMORCH_HOME` env var (user override or launcher-exported) wins.
2. Else the project's `.shmorch/home` file — a one-line absolute path that `init`
   and `sync` stamp with the skill's real location on this machine. This is what
   makes an omp-only or opencode-only install work: the skill can live anywhere.
3. Else the conventional Claude path `~/.claude/skills/shmorch` — readable by every
   CLI that supports Claude discovery, so zero-config still works when the skill is
   installed there.

**Two literal exceptions** (do NOT rewrite these to `$SHMORCH_HOME`):

- **`@`-import lines** inside context files — imports are expanded by the CLI, not
  the shell, so a `$VAR` would not resolve. `init`/`sync` stamp the real absolute
  path into these instead.
- **The resolution recipe's own default** (`~/.claude/skills/shmorch`).

When you `read` a skill file, substitute the resolved value (or use your CLI's
native skill URL if it has one — e.g. `skill://shmorch/workflows/go.md` on omp).
When you run a tool, the exported var works directly: `bash "$SHMORCH_HOME/tools/timelog.sh" …`.

---

## The context-file chain — loads on every CLI

`init` wires a chain that every CLI can pick up. The single source of truth for
project instructions is **`.shmorch/AGENTS.md`**; everything else points at it.

```
root AGENTS.md   →  @.shmorch/AGENTS.md   ┐
root CLAUDE.md   →  @.shmorch/CLAUDE.md   ┴→ .shmorch/AGENTS.md → @<SHMORCH_HOME>/shmorch-core.md
                    (.shmorch/CLAUDE.md is a one-line @AGENTS.md shim)
```

**Single-source invariant (strict — no duplication).** `.shmorch/AGENTS.md` is the ONLY
context file that carries substance (the `shmorch-core.md` import + project overrides).
Every other context file is a **pure shim** — a bootstrap comment plus one import, nothing else:

- `.shmorch/CLAUDE.md` → `@AGENTS.md`
- root `AGENTS.md` / `GEMINI.md` → `@.shmorch/AGENTS.md`
- root `CLAUDE.md` → `@.shmorch/CLAUDE.md`

Never let two context files carry the same overrides — they will drift. `init` writes them
this way; `sync` (`auto-update.md` Step 2.4) migrates any stray substance back into
`.shmorch/AGENTS.md` and reduces every other context file to a shim.

Which root file each CLI auto-loads:

| CLI | Auto-loads | Resolves `@` imports? |
|---|---|---|
| Claude Code | root `CLAUDE.md`, `.claude/CLAUDE.md` | Yes |
| omp / Pi | root `AGENTS.md` (walks to repo root), `.omp/AGENTS.md`, `.claude/CLAUDE.md` | Yes |
| Codex | root `AGENTS.md` | No (reads literally) |
| Gemini CLI | `GEMINI.md` | Varies |
| opencode | root `AGENTS.md` | Varies |
| Cursor | `.cursor/rules/*`, `AGENTS.md` | No |
| Antigravity | `AGENTS.md` | No |

Because some CLIs read `AGENTS.md` **literally** (no `@` expansion),
`.shmorch/AGENTS.md` leads with a plain-text bootstrap instruction *before* the
`@`-import, so the agent is told to read `shmorch-core.md` even when the import is
not auto-expanded:

```markdown
<!-- SHMORCH BOOTSTRAP -->
You are in a Shmorch-managed project. Before anything else, read the Shmorch
operating manual at the path on the next line. If your CLI already expanded it
inline, continue; otherwise use your file-read tool to read it now.

@/abs/stamped/path/shmorch-core.md
```

- **Expansion-capable CLIs** (Claude, omp, Pi) inline `shmorch-core.md` automatically.
- **Literal CLIs** (Codex, Cursor, Antigravity) see the instruction + the path and
  read it with their file tool.

For Gemini, `init`/`sync` also drops a root `GEMINI.md` shim (`@AGENTS.md` /
read-AGENTS.md instruction). For Cursor, an optional `.cursor/rules/shmorch.mdc`
pointer can be added; it is not required because Cursor also reads `AGENTS.md`.

---

## Capability adapter matrix

Each capability shmorch uses, and how it maps per CLI. "Fallback" is what to do when
the CLI has no equivalent — it always keeps the workflow correct.

| Capability | Claude Code | omp / Pi | Others (Codex/Gemini/opencode/Cursor/Antigravity) | Fallback |
|---|---|---|---|---|
| Skill body | `~/.claude/skills/shmorch` skill | `skill://shmorch` / claude-discovered | context-file chain only (no skill concept) | read `$SHMORCH_HOME/shmorch-core.md` + workflow files directly |
| Invocation | `/shmorch <cmd>` (SKILL.md, `$ARGUMENTS`) | `/skill:shmorch <cmd>` (`User:` arg) | type `shmorch <cmd>` as text | dispatch on the first word of whatever args arrive; read `commands/<word>.md` |
| Subagents | `Agent` tool + `SendMessage`, models `haiku`/`sonnet` | `task` tool (agents: explore/plan/reviewer/task/sonic) + `irc`, tiers `smol`/`default`/`slow` | usually none | run the step inline in the main thread |
| Safety hooks | `.claude/settings.json` + shell hooks | `.omp/hooks/pre/*.ts` (`pi.on("tool_call")`) | CLI's own approval mode | the model-enforced Safety Rules in `shmorch-core.md` |
| Session-start prompt | `SessionStart` hook | first turn / on invocation | first turn | ask go/resume/nothing on the first user turn |
| Checkpoints | `Esc Esc` / `/rewind` | `rewind` / `checkpoint` tools | git only | `/shmorch checkpoint` (git commit of state) — CLI-neutral |
| Scheduler | `CronCreate/List/Delete` | none in-REPL | none | system cron / external scheduler; document, don't rely |
| External memory | `~/.claude/projects/**/memory` | `memory://`, retain/recall | none | `docs/state/` + `docs/` in the repo (already the source of truth) |
| MCP tools | `mcp__<server>__<tool>` | `mcp://<uri>` | varies | "your CLI's MCP tools for <server>" |

**Model tiers, CLI-neutral:** where a role names a model, read it as a *tier* —
`cheap/default` for routine roles, `strong` for the adversarial critic. Map to the
CLI: Claude `haiku`/`sonnet`; omp `smol`/`default`/`slow`. Never hardcode a vendor
model name in a workflow.

---

## Subagent abstraction

`agents/TASK-PROTOCOL.md` is the contract. It is written CLI-neutrally: "spawn a
subagent with your CLI's task/agent tool." The when-to-spawn gates
(parallelizable, role-specific, low file overlap) and the role prompt template are
identical everywhere. Only the tool call differs:

- **Claude Code:** `Agent(name, model, description, prompt)`, resume via `SendMessage`.
- **omp / Pi:** the `task` tool with a `tasks[]` batch; inter-agent messaging via `irc`.
- **No-subagent CLIs:** do the role's work inline. The role file still frames the
  worldview; you just adopt it yourself instead of delegating.

Every agent prompt still includes the verbatim role-resolution line, now
`$SHMORCH_HOME`-based:

```
Read your role: check .shmorch/agents/roles/<name>.md first (project override);
if not present, read $SHMORCH_HOME/agents/roles/<name>.md (skill default).
```

---

## Launcher

`shmorch.sh` selects the CLI. It resolves `$SHMORCH_HOME`, then launches the chosen
agent (arg `--cli=<name>`, `$SHMORCH_CLI`, or first found). Claude-only env
(`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`) is set only when launching Claude. Any CLI
also works when started directly in the project — the context chain loads regardless.

---

## Where this is enforced

- `$SHMORCH_HOME` resolution: `shmorch-core.md` session-start.
- Chain generation + `.shmorch/home` + bootstrap: `workflows/init.md`.
- Propagation to existing repos + old-layout migration: `workflows/auto-update.md`.
- Subagent mapping: `agents/TASK-PROTOCOL.md`.
- Hook adapters: `templates/.claude/` (Claude), `templates/.omp/hooks/` (omp).
