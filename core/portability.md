---
loads_when: resolving $SHMORCH_HOME, touching any skill file that assumes a specific CLI, or deciding whether a new dependency (e.g. python3) is in scope — environment baseline vs agent-capability axes, context-file chain, capability adapter matrix
size: 292 lines
---

# Cross-CLI Portability

Shmorch is authored as a Claude Code skill but is designed to run under any agent
CLI that can read a context file and run a shell — omp (Oh My Pi), Pi, Codex,
Gemini CLI, opencode, Cursor, Antigravity, Devin, and Claude Code. The user must be
able to switch CLIs freely inside the same project without re-initializing.

**Revised 2026-08-11.** The original version of this doctrine treated "portability"
as one problem with one fix (a shell-only floor). It's actually two independent
problems that happen to share the word "portability," with different costs and
different fixes. Conflating them either overpays (rejecting a cheap dependency out
of a rule meant for a different risk) or underpays (hand-waving a hard capability
gap as "add a fallback"). Keep them separate:

## Axis 1 — Environment baseline (machine-level, agent-independent)

What has to be *installed on the machine* for shmorch's tooling to run. This has
nothing to do with which agent CLI is driving — a shell command runs identically
regardless of whether Claude Code, Pi, omp, Codex, Antigravity, Devin, or opencode
is the one invoking it. The relevant question is "does this developer's machine
have it," not "does this agent support it."

**Assumed present, no fallback needed** — every CLI in scope already requires a
real local dev environment to run at all (they're themselves substantial installed
programs), so these are baseline, not a burden:
- A POSIX shell (bash/zsh)
- `git`
- `python3` (added 2026-08-11 — see below)

**Available if present, never required:** `node`, `jq`. Tooling may use them
opportunistically but must have a bash-only path when absent.

**Why `python3` moved into the assumed baseline, not left optional:** it's the
same category as `git` — a near-universal baseline tool on any machine capable of
running these CLIs in the first place, not a vendor-specific or agent-specific
affordance. Requiring it costs a `pip install` for the handful of tools that use
it (currently: the sub-call request/response handler, see
[Subagent abstraction](#subagent-abstraction) below), not a rethink of what kind of
project this is. Tools that use it still degrade to a plain inline check if
`python3` or a specific package (e.g. `pydantic`) isn't found on a given machine —
same "degrade gracefully" spirit as Axis 2, just for a much cheaper reason to miss
(an uninstalled package, not a missing agent primitive).

## Axis 2 — Agent-capability matrix (per-CLI, structurally different)

What the *orchestrating agent itself* can do — native subagent/coagent spawning,
hooks, checkpoints, structured tool-call schemas. This is the axis that's actually
hard, because there's nothing to install: some CLIs simply have no equivalent
primitive, full stop. A script can't paper over "this harness has no subagent
concept" the way it can paper over "python3 isn't installed" — there is no package
to add. This axis needs a real per-capability fallback (below, and the existing
[Capability adapter matrix](#capability-adapter-matrix)), not an install step.

**Two rules make Axis 2 work:**

1. **Never hardcode the skill's install path.** Use `$SHMORCH_HOME` (below).
2. **Degrade gracefully.** Every Claude-only affordance has a fallback that works
   with nothing but a context file, a file-read tool, and a shell (plus, as of
   2026-08-11, `python3` where a tool specifically needs it). When a CLI lacks a
   feature (subagents, hooks, checkpoints), the workflow still completes — the
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

**Cloud/ephemeral-sandbox CLIs (Devin, and any future CLI in this shape) are a
fourth case, not covered by the three branches above.** These don't run on the
developer's own machine at all — each session (or cached snapshot) starts a fresh
VM with no `~/.claude/skills/shmorch` on disk and no persisted `$SHMORCH_HOME` env
var from a prior session. Branch 2 above (`.shmorch/home`) still resolves *inside*
the project repo once it's populated, but something has to populate it first, since
there's no local machine where the skill was ever installed to begin with.

The fix is a setup-script step (Devin: the per-session/per-snapshot setup script,
run before Devin starts work) that does what a human runs once via `init` on a real
machine, just automated: `git clone <shmorch skill repo URL>` to a fixed path in
the VM, then write that path into `.shmorch/home` (or export `$SHMORCH_HOME`
directly) so branch 1 or 2 resolves normally from then on. If the platform caches
the VM/snapshot across sessions on the same repo, the clone only needs to happen
once; if every session is fully fresh, it re-clones each time — cheap, since it's
only the skill directory, not project data.

**Two literal exceptions** (do NOT rewrite these to `$SHMORCH_HOME`):

- **`@`-import lines** inside context files — imports are expanded by the CLI, not
  the shell, so a `$VAR` would not resolve. `init`/`sync` stamp the real absolute
  path into these instead.
- **The resolution recipe's own default** (`~/.claude/skills/shmorch`).

When you `read` a skill file, substitute the resolved value (or use your CLI's
native skill URL if it has one — e.g. `skill://shmorch/workflows/go.md` on omp).
When you run a tool, the exported var works directly: `bash "$SHMORCH_HOME/tools/timelog.sh" …`.

**Which branch `$SHMORCH_HOME` is on is not your concern.** A project session only
ever *reads* files under `$SHMORCH_HOME` — it never checks out, switches, or depends on
a particular branch there. The skill repo may be mid-development on a feature branch
when you read from it; just read whatever is currently on disk and move on. If you
spot a real gap in a skill file while working in a different project, that's a
`self-improve` finding to file at `$SHMORCH_HOME/docs/inbox/`, never a reason to `cd`
into `$SHMORCH_HOME` and touch its git state yourself — see `core/operations.md` §
Cross-repo discipline.

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

| Capability | Claude Code | omp / Pi | Others (Codex/Gemini/opencode/Cursor/Antigravity/Devin) | Fallback |
|---|---|---|---|---|
| Skill body | `~/.claude/skills/shmorch` skill | `skill://shmorch` / claude-discovered | context-file chain only (no skill concept) | read `$SHMORCH_HOME/shmorch-core.md` + workflow files directly |
| Invocation | `/shmorch <cmd>` (SKILL.md, `$ARGUMENTS`) | `/skill:shmorch <cmd>` (`User:` arg) | type `shmorch <cmd>` as text | dispatch on the first word of whatever args arrive; read `commands/<word>.md` |
| Subagents | `Agent` tool + `SendMessage`, models `haiku`/`sonnet` | `task` tool (agents: explore/plan/reviewer/task/sonic) + `irc`, tiers `smol`/`default`/`slow` | usually none | run the step inline in the main thread |
| Safety hooks | `.claude/settings.json` + shell hooks | `.omp/hooks/pre/*.ts` (`pi.on("tool_call")`) | CLI's own approval mode | the model-enforced Safety Rules in `shmorch-core.md` |
| Session-start prompt | `SessionStart` hook | first turn / on invocation | first turn | ask go/resume/nothing on the first user turn |
| Checkpoints | `Esc Esc` / `/rewind` | `rewind` / `checkpoint` tools | git only | `/shmorch checkpoint` (git commit of state) — CLI-neutral |
| Scheduler | `CronCreate/List/Delete` | none in-REPL | none | system cron / external scheduler; document, don't rely |
| External memory | `~/.claude/projects/**/memory` | `memory://`, retain/recall | none | `docs/project/` + `docs/` in the repo (already the source of truth) |
| MCP tools | `mcp__<server>__<tool>` | `mcp://<uri>` | varies | "your CLI's MCP tools for <server>" |

**Devin's invocation shape differs from the rest of the "Others" column, worth
naming explicitly:** every other CLI here is a live REPL where a person types a
command each turn. Devin is assigned a task up front (via its web UI, Slack, the
API, or a GitHub mention) and then runs largely unattended — there's no turn-by-turn
typing of `shmorch <cmd>`. This actually degrades cleanly through the dispatch
table's existing catch-all: if the assigned task text literally contains a known
command word, it dispatches normally; otherwise it falls to the "anything else"
row — the full task description is treated as a directive addressed to Shmorch,
which is exactly the shape a Devin task already arrives in. No new dispatch logic
needed, just the observation that the catch-all row is the common case for Devin,
not the exception.

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

**Sub-call request/response handling (added 2026-08-11, `tools/subcall.py`):** a
single Python handler, shared by every workflow that makes a rote sub-call
(`go`/`resume`/`wrap`/`self-improve`/`documentarian`), rather than one bespoke
validation path per workflow. Its job is deliberately narrow and sits *around*
the tool call above, never replacing it:

- `prepare_request(workflow, args)` — validate the outgoing task parameters
  against that workflow's Pydantic model before they're embedded in the prompt
  handed to `Agent`/`task`/inline execution.
- `validate_response(workflow, raw_text)` — extract and validate the sub-call's
  returned JSON against the matching response model; on parse/validation failure,
  return the raw text as an error string (never silently drop it).
- `capability(cli_name)` — look up which primitive (Axis 2, above) this session's
  CLI has, so the orchestrating model knows whether to spawn or run inline. A
  lookup, not a decision — the actual choice to spawn and the spawn call itself
  stay the orchestrating agent's, because **no script can invoke another CLI's
  native subagent tool** — that tool call only exists inside the agent's own
  reasoning loop. The handler validates the data on both sides of a call it does
  not and cannot make itself.

Falls back to a plain inline structural check (required keys present, roughly
right types) when `python3`/`pydantic` isn't on the machine — Axis 1's fallback,
distinct from and much cheaper than Axis 2's per-CLI fallback above. Full design:
`tracks/20260721-workflow-subagent-delegation/approach-b-subagent-delegation.md`.

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
- Sub-call request/response validation (Axis 1, `python3`-dependent, all CLIs
  share it): `tools/subcall.py`, models in `agents/schemas/`.
- Hook adapters: `templates/.claude/` (Claude), `templates/.omp/hooks/` (omp).
