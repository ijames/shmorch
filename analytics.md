# Analytics — User-Facing Products

Distinct from observability. Observability answers "is the system healthy?" Analytics answers "what are users doing, and is the product delivering value?"

## The Three Questions Analytics Must Answer at Productionization

1. **Discovery** — how are users finding the product? (search, referral, direct)
2. **Engagement** — which content and interactions deliver value? (funnels, dwell, return rate)
3. **Quality** — are experiments and changes moving metrics in the right direction?

## Privacy Posture

Default: no PII, no persistent cross-session identifiers, aggregated by default. Collect what is needed to make product decisions — not everything technically available. Products that value user trust must not replicate the dark patterns of engagement-driven design.

## Stage Expectations

| Stage | Minimum |
|---|---|
| R&D | None |
| proof-sprint | Zero-config pageviews only (Vercel Analytics, Plausible, or equivalent). Core Web Vitals. No custom events. |
| productionization | Event model defined in `docs/product/analytics.md`. Custom events for key user funnel. Tool decision recorded in `decisions.md`. |
| maintenance | Dashboard per audience (product/strategy). A/B harness live. Analytics reviewed before each sprint planning. |

## Init Questionnaire Trigger

"Is this a user-facing product?" → yes → scaffold `docs/product/analytics.md` with core questions, event model stub, privacy posture, and stack decision.

## Template

`docs/product/analytics.md` — scaffolded by `init` for user-facing projects.

## Interaction with Other Dimensions

Analytics and Observability are complementary but separate: share no tooling; analytics is user-layer, observability is system-layer. Both are required at productionization.

Analytics and Progressive Delivery intersect at experiment toggles: A/B tests and % rollouts are analytics instruments. The experiment toggle owns the split; analytics owns the measurement. Define the metric and success condition before shipping the experiment toggle — otherwise codification has no trigger.

Analytics and SEO/GEO interact at the discovery layer: organic traffic attribution reveals whether SEO/GEO investment is working.
