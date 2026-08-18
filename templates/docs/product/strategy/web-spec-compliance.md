---
status: Draft
updated: YYYY-MM-DD
summary: <one line — what this file currently says>
---

# Web Spec Compliance Strategy

↑ [strategy/](index.md)

> Fill this in at intent stage for any public-facing web product. These requirements drive
> URL structure, rendering strategy, and content shape — plan before building, not after.
>
> **SEO** = ranked by traditional search (Google, Bing). **GEO** (Agent Readiness) = cited
> by AI-powered search and discoverable by agents (ChatGPT, Perplexity, Google AI
> Overviews, Claude). SEO gets you ranked; GEO gets you cited.
>
> Technical compliance (markup, headers, protocol-level SEO/GEO/accessibility/security/
> performance/privacy/resilience/i18n) is audited live against `specification.website` via
> its MCP, not hand-tracked here — see `core/web_spec_compliance.md`. Only the
> product-specific strategy — content and positioning, not markup — lives in this file.

---

## Target Queries

What are users and AI assistants searching for that should lead to this product?

### Primary (high intent)
- (define — these are the queries a user has when they already know they want what you offer)

### Discovery / category
- (define — these are the queries that surface the product to users who don't know it exists yet)

### GEO citation targets
- (define — queries where an AI assistant should cite this product as a named source)

---

## Content Model

What does each page/view contain, in what structure, to be indexable and citable?

For each page type: what is the `<h1>`, what sections follow, what is the citable claim?

| Page type | H1 | Citable claim format |
|---|---|---|
| (e.g. home) | | |
| (e.g. item detail) | | |

---

## Technical Compliance Audit

Run via the `specification.website` MCP, not a static checklist — see
`core/web_spec_compliance.md` for the tool calls and baseline-vs-delta workflow.

- Last audit date: (fill in)
- Accepted deviations (documented exceptions, not silent gaps): (list, or "none")

---

## Authority and Trust Signals

- (publisher / organization identity)
- (research citations or methodology transparency)
- (other trust signals relevant to this domain)
