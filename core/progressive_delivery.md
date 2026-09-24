---
loads_when: intake or design for a project with a deploy pipeline — deploy-vs-release, toggle taxonomy, flag lifecycle
size: 143 lines
---

# Progressive Delivery — First-Class Dimension

## Principle

**Deploy ≠ Release.** Code goes to production dark. Release is intentional. The flag is the release gate, not the deploy pipeline.

Every feature is built dark-by-default. Deployment is mechanical. Release is a product decision.

---

## Why This Matters

CI/CD pipelines that auto-deploy on every green build are only safe if deploying can never change user-visible behaviour without intent. Feature flags provide that guarantee: the pipeline runs continuously; user impact is decoupled and controlled.

Without this decoupling, the deploy pipeline becomes the release gate — slowing engineering velocity to the cadence of deliberate product decisions.

---

## Toggle Types

Martin Fowler's taxonomy. Use the right type — each has a different owner, lifespan, and codification path:

| Type | Purpose | Owner | Lifespan |
|---|---|---|---|
| **Release toggle** | Ship dark, enable when ready | Engineering / PM | Short — codify after launch |
| **Experiment toggle** | A/B test, % rollout | Growth / PM | Short — codify after data |
| **Ops toggle** | Kill switch, circuit breaker | Ops / SRE | Permanent — infrastructure |
| **Permission toggle** | Per-customer / per-role | CS / Product | Long-lived |
| **Migration toggle** | Gates a data/message-shape migration's own progress, not a feature's visibility | Engineering | Until stage 2 verified — see Expand / Migrate / Contract below |

---

## Scale Ladder

| Level | Mechanism | Runtime changeable? |
|---|---|---|
| Dev / CI | Env var | No (redeploy) — acceptable for local dark |
| Production | Feature flag service + admin UI | Yes — no deploy needed |

Skip config files (TOML, INI) for release flags — changing them requires a deploy, which defeats the purpose. Go straight from env var (CI/staging) to a flag service with admin panel (production runtime control).

**Admin panel is not optional.** Flags proliferate fast. Non-engineers need to reach them. Build or adopt the UI early — before you have more flags than you can track in a spreadsheet.

Self-hosted: Unleash, GrowthBook, Flagsmith, Flipt.
Managed: LaunchDarkly, Statsig, Split.io.

---

## Dark Default Rule

**Absence means dark.** If the flag key is missing from config or the flag service, the feature behaves as if it doesn't exist. Never invert this — a missing flag that enables a feature is an accidental release waiting to happen.

---

## Codify Phase

After a feature is released and stable — remove the toggle. This is a named lifecycle phase, not optional cleanup:

1. **Release toggles**: remove the conditional, delete the dark branch. Code becomes straight-line.
2. **Experiment toggles**: choose the winner, delete the losing branch, codify the winner.
3. **Ops toggles**: do not codify. They are permanent infrastructure — the switch is the point. Give them a home in ops config, not app config.

Uncodified release toggles are technical debt. They accumulate, obscure intent, and make the codebase harder to read.

---

## Data & Message-Shape Migrations — Expand / Migrate / Contract

The sections above govern **code-path** visibility (is the feature dark or live to users).
This one governs **data and message-shape authority** — which storage column/table, or
which SQS/queue payload shape, is the source of truth. It needs a stronger guarantee than
Dark Default: not just "absence means dark" at launch, but "every non-final stage must be
safely flippable in *both* directions, with no data loss," because the old and new
representations coexist and both must stay correct throughout the bake period. A single
Toggle Types row doesn't capture that the flag here gates a *migration's own progress*, not
a feature's visibility — that's the **Migration toggle** row above.

Three stages (four for schema/data and infra), always named explicitly at spec time:

1. **Expand (dark).** Build the new structure (column, table, SQS message field) fully
   alongside the old. Nothing observable changes. If the new structure needs data the old
   one already produces, dual-write both on every write — the new structure accumulates
   real data while the old path stays authoritative and untouched. No flag is required at
   this stage if dual-write is unconditional and cheap; a flag is required once any *read*
   path could branch (stage 2).
2. **Migrate / cutover (flagged, reversible).** Once the new structure is verified complete
   and correct (e.g., a parity check against the old path's output), flip a flag so reads —
   and, for message-shape changes, newly-produced messages — move onto the new structure.
   The old structure keeps being written and kept intact throughout this stage purely as a
   safety net. **The flag must be flippable back to stage-1 behavior at any point in this
   stage with zero data loss**, since the old path never stopped. This is the property that
   makes the migration itself agile rather than a single big-bang cutover.
3. **Contract (one-way, its own release).** Only after stage 2 has baked and settled: a
   final, explicit release removes the old structure, the dual-write, the old read path, and
   the flag itself — this is the Codify Phase above, applied to a migration rather than a
   feature. Not reversible, and deliberately its own release, never bundled into stage 2's
   cutover. Contract removes *code* risk; for schema and infrastructure the old storage/host
   stays in place, dormant.
4. **Purge (gated, its own later release; schema/data and infra only).** Physically drop the
   old column, table, or host. Gate: the pre-migration data is confirmed ported to the new
   structure, *or* it's safely archived (snapshot/backup) or past its retention window —
   either alone is enough. Purge removes *data* risk (the last copy), which is why it is
   separate from Contract. N/A for message shape and code path — nothing physical is left
   once Contract lands.

Human-facing diagram and step-by-step checklist (not for agent loading):
`docs/reference/instructions/expand-migrate-contract.html`, `expand-migrate-contract-checklist.md`.

---

## Who Controls

| Role | Toggle type they own |
|---|---|
| Engineers | Define flags; implement dark features |
| Product managers | Release toggles — flip without a deploy |
| Growth / marketing | Experiment toggles — % rollout, A/B |
| Ops / SRE | Ops toggles — kill switches, circuit breakers |
| Customer success | Permission toggles — per-customer access |

The tool choice determines who can reach the controls. An env var gates access behind engineering + a deploy. A flag service UI gives access to whoever has a login.

---

## At Spec Time — Required Answers

Every feature spec must answer before implementation begins:

1. **Toggle type** — which Fowler type applies?
2. **Flag name** — what is the key? (`feature.<name>`, `ops.<name>`, `experiment.<name>`)
3. **Absence behavior** — what happens when the flag is missing? (answer: dark)
4. **Owner** — who flips this flag?
5. **Codify condition** — what triggers removal? (e.g., "after 2 weeks stable in production")

For ops toggles additionally: what does "off" mean operationally? (rate limit? redirect? 503? silent no-op?)

---

## Build Workflow Hook

> When designing a feature, the spec must answer "what is the toggle?" before implementation begins. Not as overhead — as the minimum viable release strategy.

At implementation: the feature is always wrapped in a conditional from the first commit. Never ship a feature unwrapped and retrofit a flag later.

For data/message-shape work specifically: does this introduce a second storage/message
shape? If so, name its three stages (Expand / Migrate / Contract) and each stage's
flip-back guarantee before implementation begins.

