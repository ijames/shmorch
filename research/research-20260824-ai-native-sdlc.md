### Research Report — 2026-08-24
**Focus:** Anthropic's *AI-Native SDLC Playbook* vs. Shmorch orchestration fundamentals
**Source:** https://claude.com/blog/the-ai-native-sdlc-playbook
**Shmorch baseline read:** `shmorch-core.md`, `agents/orchestrator.md`, `agents/TASK-PROTOCOL.md`, `core/index.md` + doctrine files, `workflows/` phase set

---

## 1. What each thing actually is

The two systems are not the same kind of artifact, and most of the diff falls out of that.

**The Playbook is a pipeline specification for an organization.** Six stages (Plan, Design, Build, Test, Deploy, Maintain), each committing one machine-readable artifact that triggers the next stage. Its unit of work is a change moving through a governed pipeline. Its enforcement mechanism is deterministic infrastructure — hooks, managed settings, branch protection, CI evals. Its subject is a team of humans with an audit trail obligation. Orchestration in the Playbook is *humans orchestrating agents*: one engineer running several `claude --worktree` sessions.

**Shmorch is an agent persona plus a state machine for a session.** Its unit of work is a conversation that survives across context resets. Its enforcement mechanism is doctrine — markdown that the model reads and is expected to comply with. Its subject is one developer plus a spawned agent team. Orchestration in Shmorch is *an agent orchestrating agents*: a named orchestrator with a role registry, spawn gates, and return-line contracts.

So: the Playbook is strongest exactly where Shmorch has no purchase (deterministic enforcement, multi-human governance, closed operational loop), and Shmorch is strongest exactly where the Playbook is silent (agent-to-agent coordination, cost, context, portability, cross-session continuity).

---

## 2. Diff matrix

| Dimension | Playbook | Shmorch | Verdict |
|---|---|---|---|
| **Unit of work** | A change moving through 6 stages | A session with persistent state | Different, not competing |
| **State artifacts** | `intent.md` → `spec.md` → `plan.md` → PR → back to `intent.md` | `docs/project/{context,stack,spec,session}.md` + `plan/` tracks + permanent `decisions/` | Shmorch richer; Playbook more legible |
| **Trigger model** | Commit on artifact N triggers stage N+1 (eventually automatic) | Human types `/shmorch <command>`; SessionStart asks go/resume/nothing | **Playbook better** for throughput |
| **Loopback** | Stage 6 anomaly → new `intent.md` → Stage 1 | `check-inbox`, `discover`, `prioritize`, `research`, `self-improve` | Split: see §4.6 |
| **Enforcement** | Hooks (allow/deny/ask), managed settings, `permissions.deny`, OS sandbox, branch protection | Markdown doctrine + safety rules + "Proceed?" gate | **Playbook decisively better** |
| **Policy carrier** | Skills (versioned, owner-approved, org-wide) | `core/` doctrine tree (~7,300 lines across 49 files) | Playbook better governed; Shmorch better specified |
| **Repo instructions** | `CLAUDE.md`, explicitly ~1 page max | `shmorch-core.md` (203 lines) + lazy-loaded `core/` | **Playbook better** on discipline; see §5 risk |
| **Test doctrine** | Feedback loop in-session; quantified targets in `CLAUDE.md`; failing-test-first for bugs, test file locked by hook | Prime Directive (no test, no code); Testing Depth Ladder by stage; always-red rule; temporal propagation; `verify.md` parity check | **Shmorch better** on ordering rigor; **Playbook better** on mechanical enforcement of it |
| **Config regression** | 20–50 real tasks as CI evals; every incident becomes a permanent eval; config changes gated on eval pass rate | None. `self-improve` and `auto-update` change doctrine with no regression suite | **Playbook decisively better** |
| **Code review** | Standardized AI passes, `REVIEW.md` (severity thresholds, skip patterns, nit caps), `@claude` comment resolution, human approval via branch protection | `critic` role at phase boundaries (strong tier), `cross-functional-mediator` at seams, BLOCKER gate | Split: Shmorch better *pre*-merge design critique, Playbook better *at* merge |
| **Separation of duties** | Explicit: agent cannot approve its own code; production deploy needs named release-manager authorization | Implicit: "never push without confirmation", skill edits require branch → PR → developer merge | **Playbook better**, and it is a real gap |
| **Deploy** | Env tiers (dev free / staging staged / prod hook-gated), MCP deploy tools, scoped short-lived tokens, sandboxed CI | `progressive_delivery.md` (deploy ≠ release, flag as release gate), `deployment.md` (manifest sync, cross-platform wheels), `git-discipline.md` | **Shmorch better** on release semantics and build-reality traps; Playbook better on authorization |
| **Maintain / ops** | Deterministic detector (mean ± 3σ, Western Electric), tiered response 1σ log / 2σ read-only diagnose / 3σ propose-PR, Claude Tag in Slack, post-mortems to versioned lessons files | `observability.md` as a design-time dimension only. No detection layer, no response tiers, no incident loop | **Playbook decisively better** |
| **Agent orchestration** | Human runs parallel worktrees; subagents for repeated tasks. One paragraph of guidance | Orchestrator role, 14 role files, one-role-per-agent rule, spawn checklist (parallelizable + role-specific + low file overlap), named sessions resumable via SendMessage, `DONE:` return-line contract with BLOCKER/CRUFT/GAP flags, ~4 parallel cap | **Shmorch decisively better** |
| **Cost discipline** | Not addressed | Default-to-inline, tier mapping (default vs. strong), never spawn for <2min tasks or high file overlap, targeted reads | **Shmorch better** |
| **Context management** | Only implicit (subagents as separate context windows) | `workflows/context.md`, compaction triggers table, phase-boundary `/clear`, "say it once, never nag" | **Shmorch better** |
| **Human gate placement** | 5 stage gates: intent acceptance, risk escalation, plan approval, code-owner sign-off, incident triage | Per-change: 95% confidence interview, one question at a time, "Proceed?" before any code | Split: see §4.1 |
| **Metrics** | Leading + lagging pair per stage, explicitly named | `timelog.sh` events only. No metrics program | **Playbook better** |
| **Portability** | Claude Code, Claude Design, Claude Tag, MCP. Product-locked by design | `$SHMORCH_HOME` indirection, capability adapter matrix, graceful degradation to inline roles on CLIs without subagents | **Shmorch better** |
| **Onboarding a second human** | First-class (git history is the audit trail, skills are institutional knowledge, `CLAUDE.md` is day-one onboarding) | Not modeled. Everything assumes one developer in conversation | **Playbook better** |

---

## 3. Where the two genuinely agree

Worth stating, because the overlap validates both:

- **Plan before code, as a written artifact.** Playbook `plan.md` in plan mode ≡ Shmorch's "plans before code, specs before plans" + `workflows/plan` gate.
- **Version control as the audit trail.** Both refuse to let decisions live in conversation. Shmorch's "nothing lives only in conversation" and permanent `decisions/` is the same instinct as the Playbook's artifact chain.
- **Policy applied at generation time, not review time.** Playbook skills constrain `spec.md` as it is written; Shmorch's First-Class Dimensions (observability, web spec, analytics, progressive delivery) are raised at intent stage.
- **Institutional knowledge is versioned, not tribal.** Skills ≡ `core/`. Both treat the rules file as a code artifact with owners.
- **Tests as the definition of behavior.** Both put "the test encodes intent, don't edit the test to pass" in load-bearing position — Playbook via a hook that locks the test file, Shmorch via a safety rule.
- **Subagents as separate contexts.** Playbook: a verifier that runs the app without changing code. Shmorch: one role per agent, because "a single continuous context tends to self-agree".

---

## 4. Where one strategy is better than the other

### 4.1 Human gate placement — Playbook better at scale, Shmorch better for correctness

Shmorch gates *per change*: 95% confidence, one question at a time, "Proceed?" and wait. The Playbook gates *per stage*: five named checkpoints, everything between them automated.

Shmorch's model produces higher per-change fidelity and is the right shape for R&D and proof-sprint work where the developer's intent is still forming. It also does not scale: it requires the human to be present and answering questions throughout, which is precisely the bottleneck the Playbook is designed to remove.

The Playbook's model scales but assumes the spec is genuinely good, because nothing re-interviews the human between the spec gate and the code-owner gate. It bets on skills + hooks catching what the interview would have caught.

**Take:** the Playbook's stage gating is the correct target state; Shmorch's interview intensity should be a function of `context.md`'s `stage` field, the same way the Testing Depth Ladder already is. `maintenance`-stage work does not need a 95% confidence interview per change.

### 4.2 Enforcement — Playbook decisively better, and this is Shmorch's largest structural weakness

Shmorch's entire compliance model is "the model reads the markdown and complies." Every rule in `core/` is probabilistic. The Playbook's insight is a clean separation:

- **Skills** = probabilistic, expressive, for judgment ("how to write a secure endpoint")
- **Hooks** = deterministic, narrow, for invariants ("this path cannot be edited", exit code 2 blocks)
- **Managed settings** = non-negotiable, not engineer-overridable

Shmorch has rules that are plainly hook-shaped and are currently prose: "never hand-edit auto-generated files", "never change test logic to make tests pass", "sync deployment manifests after any dependency change", "never push without confirmation", "skill edits go through branch → PR". Each of those is one hook away from being unbreakable instead of merely instructed.

This is the single highest-value import.

### 4.3 Config regression testing — Playbook decisively better, and this is a live risk for Shmorch

Shmorch has `self-improve`, `auto-update`, `research`, and `learn` — four commands that mutate its own doctrine — and zero regression coverage on the result. The Playbook's answer is a 20–50 task eval suite in CI, gated on pass rate, with every production incident becoming a permanent eval.

Shmorch is arguably *more* exposed than a typical `CLAUDE.md` setup, because it self-modifies deliberately and its doctrine tree is large enough that a change in one file can contradict another. `self-improve` without evals is an unverified deploy to the thing that governs every future session.

### 4.4 Maintain stage — Playbook decisively better; Shmorch has no equivalent

Shmorch's `observability.md` says what to instrument. It does not say what happens when the instrument fires. The Playbook's tiered response (1σ log / 2σ read-only diagnose / 3σ propose PR) with a *deterministic, model-free detection layer* is the design Shmorch is missing, and the handoff — anomaly becomes `intent.md`, re-enters Stage 1 — is the piece that makes the SDLC actually a cycle rather than a line.

Keeping the model out of detection is the subtle correct call: detection must not hallucinate, diagnosis may.

### 4.5 Orchestration — Shmorch decisively better

The Playbook's orchestration content is thin: run several worktrees, use subagents for repeated tasks, the engineer's role shifts to review. There is no guidance on when spawning is worth it, no role taxonomy, no return contract, no gating on subagent findings, no parallelism cap, no model-tier economics.

Shmorch has all of it, and the specific rules are good ones: the three-condition spawn test, the file-overlap veto, one role per agent with the self-agreement rationale, named sessions resumable rather than re-spawned, and a structured return line the orchestrator must gate on. If the Playbook describes the org-level pipeline, Shmorch describes what happens inside a single Build-stage box — and describes it far better.

### 4.6 Loopback — split, and Shmorch's is more interesting

The Playbook's loop is incident-driven: production breaks, that becomes intent. Shmorch's loop is improvement-driven: `discover`, `research`, `prioritize`, `self-improve`, `check-inbox`, `learn` — it hunts for work and for better practice without waiting for a failure.

Neither has the other's. The Playbook has no mechanism for "the team should adopt a better practice"; Shmorch has no mechanism for "production is 3σ out." They compose.

### 4.7 Deploy-time reality — Shmorch better on two things the Playbook omits entirely

`progressive_delivery.md`'s "deploy ≠ release, the flag is the release gate" is a materially better model than the Playbook's environment tiers, which conflate the two: gating the *deploy* to production behind a release-manager hook is exactly the coupling progressive delivery exists to break. The Playbook's approval gate is the right control on the wrong object.

`deployment.md`'s manifest-sync rule and cross-platform wheel constraint are the kind of thing that only comes from being burned, and the Playbook has no equivalent. An `intent → spec → plan → merged PR` chain with a green CI can still ship a Lambda that fails to build on arm64.

### 4.8 Documentation model — Shmorch better, with a caveat

Shmorch's two-tier system (in-flight `docs/project/` vs. permanent `decisions/` and `architecture/`), graduation rules, skeleton principle, and "rewrite, don't layer amendments" is a genuinely more sophisticated knowledge model than the Playbook's `CLAUDE.md` + skills. The permanence rule for decisions is the good part: the Playbook's audit trail is git history, which records *what changed* but not *what was rejected and why*.

Caveat in §5.

---

## 5. Risk the Playbook surfaces about Shmorch

The Playbook says `CLAUDE.md` should be **about one page**, and treats context economy as a first-order concern. Shmorch is ~7,300 lines across 49 markdown files, and mitigates this with lazy loading (`loads_when:` frontmatter, `core/index.md` as pointer, dispatch-on-first-word in `SKILL.md`).

The mitigation is real and well-built. But two failure modes are not addressed:

1. **Nothing measures whether lazy loading works.** There is no check that a session loaded the doctrine it should have. A rule that exists in `core/` but is never loaded at the moment it applies is indistinguishable from a rule that does not exist.
2. **Contradiction between doctrine files is unpoliced.** 49 files with cross-references and no consistency test. The Playbook's eval suite is the answer to this and Shmorch does not have it.

`always`-loaded content is the budget that matters, and Shmorch's is `shmorch-core.md` (203 lines) + `core/index.md` (27) — which is comfortably inside the Playbook's implied ceiling. So the discipline is being kept where it counts. The exposure is in the tail.

---

## 6. Applicability ranking — what Shmorch should actually take

| # | Import | From | Applicability | Notes |
|---|---|---|---|---|
| 1 | **Hooks for the invariants already written as prose** | Stage 3/5 | **High** | Cheapest, highest leverage. Start with: auto-generated files, test-logic edits, deployment manifest staleness, skill-file direct commits to main |
| 2 | **Eval suite gating `self-improve` / `auto-update`** | Stage 4 | **High** | Shmorch mutates its own doctrine with no regression net. 20–50 real tasks, run on any `core/`-tree change |
| 3 | **Tiered anomaly response + intent handoff** | Stage 6 | **High** | Closes the loop. Deterministic detection layer, no model. Feeds existing `plan/` + `check-inbox` machinery directly |
| 4 | **Separation of duties, stated** | Cross-cutting | **High** | "The agent cannot approve its own work" belongs in Safety Rules verbatim. Currently only implied |
| 5 | **`REVIEW.md` — standardized review passes with severity thresholds and nit caps** | Stage 5 | **Med-High** | Complements the `critic` role rather than replacing it. Critic works phase boundaries; REVIEW.md works the diff |
| 6 | **Leading/lagging metric pair per workflow** | Cross-cutting | **Med** | `timelog.sh` already emits the events. The metrics are mostly derivable already |
| 7 | **Stage-scaled human gating** | §4.1 | **Med** | Make the 95% confidence gate a function of `context.md` `stage`, mirroring the Testing Depth Ladder |
| 8 | **Commit-triggered stage advance** | Cross-cutting | **Med** | Shmorch's phases are conversation-triggered. Artifact-triggered advance is more throughput, but conflicts with the interview model — needs #7 first |
| 9 | **Visual verification loop (implement → screenshot → compare → adjust)** | Stage 4 | **Med** | Concretizes the existing "pixel-perfect QA" standard into a runnable loop |
| 10 | **Permission tiers / managed settings / sandbox** | Cross-cutting | **Low** | Solves an enterprise problem Shmorch does not currently have. Revisit if Shmorch goes multi-developer |

Not recommended: the Playbook's environment-tier deploy gating (see §4.7 — `progressive_delivery.md` is the better model), and Claude Tag (product-specific, breaks portability doctrine).

---

## 7. One-line summary

The Playbook is a better **governance** model and a better **enforcement** model; Shmorch is a better **orchestration** model and a better **knowledge** model. The four highest-value imports are all enforcement: hooks for existing prose rules, evals for self-modification, a detection-and-response tier, and an explicit separation-of-duties rule.
