---
loads_when: always — entry pointer for the core/ subtree, read before falling back to frontmatter-traverse.sh
size: 31 lines
---

# Core Doctrine

Doctrine files loaded on demand by `shmorch-core.md`, workflows, and roles. These capture the *why* and *what* — the principles that govern how Shmorch works. Procedures (step-by-step) live in `workflows/`.

| File | Contents |
|---|---|
| `tdd.md` | Prime Directive, Testing Depth Ladder (stage + form), Temporal Propagation, Always-Red Rule, branch roles, AC sync |
| `documentation.md` | Skeleton Principle, Two-Tier Knowledge System, graduation rules |
| `changelog.md` | Architecture Changelog — migration ledger `auto-update.md` reads mechanically to backfill projects on old rules; not doctrine, not loaded by default |
| `ux.md` | UX Philosophy — all components dynamic, animation as cognitive load management |
| `engineering-standards.md` | Writing conventions, cost-vs-quality tradeoffs, E2E bug reproduction, pixel-perfect QA, fix any lint/test issue you see |
| `override.md` | Workflow/role override pattern (extend vs supersede), graduation rule, fat-copy anti-pattern |
| `observability.md` | Logs, metrics, traces — stage expectations, build track rule |
| `web_spec_compliance.md` | Web spec compliance — SEO, Agent Readiness, GEO/AEO, accessibility, security, performance, privacy, resilience, i18n; per-surface/audience scoping, stage ladder; audited live via the `specification.website` MCP |
| `analytics.md` | User behavior analytics — event model, privacy posture, funnel coverage |
| `progressive_delivery.md` | Deploy ≠ Release — toggle taxonomy, flag lifecycle, codify phase |
| `deployment.md` | Deployment manifest sync — dev env ≠ bundle, cross-platform wheel constraints |
| `git-discipline.md` | Branch hygiene — pull after merge, rebase before work, never batch-merge |
| `cross-functional.md` | Cross-functional artifact usability — intimacy gradient, naming-as-contract, discipline boundary signals |
| `portability.md` | Cross-CLI portability — `$SHMORCH_HOME` indirection, context-file chain, capability adapter matrix, graceful degradation |
| `operations.md` | Timing events, comms notifications, vacuum protocol, checkpoints, VERSION bump rule, skill-change branch/PR workflow |

Stack-specific tooling notes (only load when the project's stack includes that
technology) live outside `core/` in `$SHMORCH_HOME/technologies/` — see
`technologies/index.md`. `core/` is universal doctrine; `technologies/` is optional,
per-technology context.
