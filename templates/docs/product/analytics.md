# Analytics Strategy

↑ [Product](index.md)

**Status:** Intent defined — implementation backlogged

---

## What Analytics Is (and Isn't)

**Analytics ≠ observability.** They answer different questions:

| Layer | Questions answered | Audience |
|---|---|---|
| **Observability** | Is the system working? Errors, latency, failures | Ops / engineering |
| **Analytics** | What are users doing? Which content performs? Where do they drop off? | Product / strategy |

---

## Core Questions

### User Behavior
<!-- What actions are users taking? What paths do they follow? -->

### Content / Feature Performance
<!-- Which features and content drive engagement and value? -->

### Funnel
<!-- Key conversion path from entry to value delivery -->

---

## Event Model

| Event | Properties | When |
|---|---|---|
| `page_view` | `path` | Any route visited |
| <!-- add events per feature track --> | | |

### Privacy Posture

[Define before writing instrumentation code:]
- PII policy — what user identifiers, if any, are captured
- Cookie/storage policy — session vs persistent
- Cross-session tracking policy — aggregated vs individual paths
- Disclosure — what the privacy page states

---

## Stack Decision

**Deferred to productionization.** For proof-sprint: zero-config pageview tool only.

| Option | Strengths | When to use |
|---|---|---|
| Vercel Analytics | Auto Core Web Vitals, zero config | Always if deployed on Vercel |
| Plausible | Privacy-first, no cookies, GDPR-clean | Privacy-first public products |
| PostHog | Events + flags + session recording, open source | Full product analytics |
| Custom | Full control, reuses existing DB | When existing infra handles it |

Record final tool decision in `decisions.md` before writing instrumentation code.

---

## Stage Expectations

| Stage | Minimum |
|---|---|
| R&D | None |
| proof-sprint | Zero-config pageviews only. No custom events. |
| productionization | Event model live. Key funnel instrumented. Tool decision recorded. |
| maintenance | Dashboard per audience. A/B harness live. Reviewed before each sprint. |

---

## Implementation Backlog

1. Enable zero-config pageview tool
2. Define event schema in `docs/architecture/analytics-events.md`
3. Event emitter utility — thin wrapper with swappable sink
4. Tool decision → `decisions.md`
5. Key funnel instrumentation
6. Dashboard: funnel view
7. A/B harness (if needed)
