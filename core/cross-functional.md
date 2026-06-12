# Cross-Functional Artifact Usability

Any artifact touched by more than one discipline must be legible to all of them. The right abstraction level is determined by the *cognitive distance* between the disciplines that share it — not by what's convenient for the author.

---

## The Intimacy Gradient

Some discipline pairs share a mental model. Others meet only at an artifact boundary, in languages that are alien to each other.

| Boundary | Example | Cognitive distance | Implication |
|---|---|---|---|
| Low | DB ↔ ORM / Backend code | Engineers share the model | Tight naming is fine; implementation detail is acceptable |
| Medium | Backend API ↔ Frontend consumer | Contract-level understanding | Schemas and field names must be self-describing |
| High | JSX ↔ CSS / Tailwind | Two alien languages sharing a file | Naming is a cross-functional contract |
| High | Terraform / CloudFormation ↔ Python app | Infrastructure-as-code vs. runtime code | Resource names must carry intent, not just IDs |
| High | Security controls ↔ Application code | Policy language vs. implementation | Control names must map to intent, not mechanism |
| High | Layout spec ↔ Component code | Designer artefact vs. engineer artefact | Component names must match the design system vocabulary |
| Variable | Admin tooling ↔ any domain | Depends on who operates it | Legibility requirement scales with operator distance from the code |

The higher the cognitive distance, the more naming and abstraction become a shared contract rather than an implementation detail.

---

## The Naming-as-Contract Principle

At high cognitive-distance boundaries, a name is not just a label — it is the interface between disciplines. Bad naming at these boundaries creates cognitive overload, bugs, and rework.

**The test:** Can someone from the *other* discipline read this artifact and orient without a decoder ring?

- A designer reading JSX: does `<HeroSection>` make sense? Does `<Div3>` or `<StyledWrapper2>` make sense?
- A developer reading a Terraform module: does `module "api_gateway_prod"` make sense? Does `module "resource_47b"` make sense?
- A non-Tailwind engineer reading a component: does `className={styles.productCard}` make sense? Does `className="flex gap-2 rounded-lg text-sm font-medium hover:bg-slate-100 dark:hover:bg-zinc-800 transition-colors"` make sense?
- A backend engineer reading an event schema: does `user.checkout.completed` make sense? Does `ev_3b_fin_ok` make sense?

**The dial:** Abstract enough that the other discipline can navigate. Literal enough that the authoring discipline doesn't lose precision. Neither side should need an interpreter.

---

## Where This Applies

Anywhere two disciplines share an artifact and one of them could be confused by what the other wrote:

- JSX component names (engineer → designer)
- CSS class identifiers and Tailwind component abstractions (engineer → engineer-who-doesn't-know-Tailwind)
- Terraform / CloudFormation resource and module names (infra → app developer)
- API field names and route paths (backend → frontend / mobile / external)
- Database table and column names (DBA → application developer)
- Analytics event taxonomies (data → product / engineer)
- Admin UI labels and action names (engineer → operator / manager)
- Security policy and IAM role names (security → developer)
- CI/CD pipeline step and job names (DevOps → any engineer reading the log)

---

## Signals That Trigger This Review

The cross-functional mediator should be active whenever:

- Two or more roles from different disciplines are producing artifacts simultaneously
- The output artifact will be read or maintained by someone outside the authoring discipline
- A naming review or audit is in scope (`/shmorch vacuum`, phase-boundary critic pass)
- The work touches a known high-cognitive-distance boundary (JSX/CSS, IaC/app, API schema, event taxonomy)
