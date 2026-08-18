---
status: Draft
updated: YYYY-MM-DD
summary: <one line — what this file currently says>
---

# Web Spec Compliance Strategy — <surface name>

↑ [strategy/](index.md)

> One of these per distinct web-facing surface (public site, public app, internal/admin
> panel) — see `core/web_spec_compliance.md` § Surfaces and Audience Tiers. A project with
> a single surface (or one multitenant surface, single audience) keeps this filename as-is;
> additional surfaces get `web-spec-compliance-<surface-slug>.md` siblings. A project with
> **no** web-facing surface at all doesn't scaffold this file — the decision is recorded
> instead in `docs/project/context.md`'s Dimension Applicability section.
>
> **SEO** = ranked by traditional search (Google, Bing). **GEO** (Generative Engine
> Optimization) / **AEO** (Answer Engine Optimization) = cited by AI-powered search
> (ChatGPT, Perplexity, Google AI Overviews, Claude) — both terms are in real industry use
> for the same practice. Distinct from **Agent Readiness**, the technical substrate
> (llms.txt, MCP/A2A discovery) GEO/AEO strategy builds on — see
> `core/web_spec_compliance.md` § Terminology.
>
> Technical compliance (markup, headers, protocol-level SEO/Agent-Readiness/accessibility/
> security/performance/privacy/resilience/i18n) is audited live against
> `specification.website` via its MCP, not hand-tracked here — see
> `core/web_spec_compliance.md`. Only the product-specific strategy — content and
> positioning, not markup — lives in this file.

## Surface & Audience

- **Surface:** (e.g. "public marketing site", "customer-facing app", "internal admin panel")
- **Audience:** Public / Internal (authenticated-only) / Mixed-multitenant (single audience)
- **Applicable categories:** (default to the full 10 for Public; for Internal, SEO and Agent
  Readiness are usually N/A — see the table in `core/web_spec_compliance.md`)

---

## Target Queries

Public surfaces only — an internal/authenticated-only surface isn't meant to be found via
search or cited by AI, so this section is N/A there (leave it noting that instead of
filling it in).

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
