# Progressive Delivery — First-Class Dimension

> **Status: Draft concept** — not yet wired into `shmorch-core.md`.
> When integrated: referenced via `@progressive_delivery.md` in the First-Class Dimensions section;
> "At spec time" questions added to the spec checklist; build workflow note added to `workflows/build.md`.

---

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

---

## Shmorch Core Integration Notes

When promoting this from draft to active:

- Add to `shmorch-core.md` First-Class Dimensions section with an `@progressive_delivery.md` include
- Add "At spec time" checklist to `workflows/spec.md`
- Add build hook to `workflows/build.md` (pre-implementation checklist item)
- Consider: does init scaffold a `docs/product/progressive-delivery.md` stub for web-facing or user-facing projects? Probably yes — alongside analytics and SEO/GEO.
