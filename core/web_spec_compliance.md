---
loads_when: intake, design, or review for a web-facing project — SEO, Agent Readiness, GEO/AEO, accessibility, security, performance, privacy, resilience, i18n audit; surface/audience scoping
size: 120 lines
---

# Web Spec Compliance — Web-Facing Projects

`specification.website` is the source of truth for what a public website must get right —
168 items across 10 categories, each tagged required/recommended/optional/avoid, sourced
from WHATWG/W3C/IETF/WCAG. Query it live rather than hand-maintaining a checklist here —
the spec evolves from its own GitHub repo; a copy pasted into this file would drift stale.

## MCP

Server: `https://mcp.specification.website/mcp` (stateless, no auth, CORS-open — added
user-scope, available in every project). Tools:
- `search(query)` — full-text search
- `list_topics()` — filtered index by category/status
- `get_topic()` — canonical Markdown, cited sources
- `get_checklist({status})` — tickable audit template
- `get_changes({since})` — delta since a prior audit date

## Categories

Foundations, SEO, Accessibility, Security, Well-Known URIs, Agent Readiness, Performance,
Privacy, Resilience, Internationalisation.

This supersedes shmorch's former `seo_geo.md` — SEO was 1 of these 10 categories, and
Agent Readiness covers what `seo_geo.md` called GEO's technical substrate, both more
thoroughly sourced here than a hand-written doctrine file could stay. `observability.md`,
`analytics.md`, and `progressive_delivery.md` remain separate dimensions — system health,
user behavior, and release process aren't in this spec's scope.

## Terminology — Agent Readiness vs. GEO/AEO

Not the same thing, though related:

- **Agent Readiness** (spec.website's actual category) — protocol/infrastructure: `llms.txt`,
  structured data for agents, MCP/A2A/Agent Skills discovery, robots rules for AI
  crawlers. Binary, auditable, sourced.
- **GEO** (Generative Engine Optimization) / **AEO** (Answer Engine Optimization) — the
  content-strategy discipline of getting cited *in* generated AI answers (ChatGPT,
  Perplexity, AI Overviews). Both terms are in real industry use for the same practice;
  neither has fully displaced the other as of this writing. Spell out whichever term is
  used on first mention per file — "GEO" alone collides with "Geographic" in a reader's
  mind, so never leave it bare.
- Agent Readiness is a prerequisite substrate GEO/AEO strategy builds on (e.g. `llms.txt`
  makes a site legible to agents; what content actually gets cited is a separate,
  judgment-driven content question outside this spec's scope — captured in the project's
  own `web-spec-compliance*.md`, not audited by the MCP).

## Surfaces and Audience Tiers

A project can have more than one distinct web-facing surface (a public marketing site, a
public app, an internal/authenticated-only admin panel) — each gets its own audit scope,
because applicable categories differ by audience:

| Category | Public surface | Internal / authenticated-only surface |
|---|---|---|
| SEO | Full | N/A — compliant answer is usually to block indexing (`noindex`, `robots.txt` disallow), not to rank |
| Agent Readiness | Full | N/A for the same reason — don't publish `llms.txt`/discovery for a surface that shouldn't be found |
| Accessibility, Security, Performance, Privacy, Resilience, Foundations | Full | Full — audience doesn't reduce these |
| Well-Known URIs | Full | Partial — security-relevant ones (e.g. `security.txt`) still apply; discovery ones don't |
| Internationalisation | Full if multi-locale | Full if multi-locale |

A single surface serving many tenants with one consistent audience (e.g. a multitenant
SaaS app, all tenants public) is still one audit scope — heterogeneity of *tenants* isn't
heterogeneity of *audience tier*.

## Stage Expectations

Reuses the project's `stage` field (`shmorch-core.md` § Project Stage) as the rigor floor.
A high-traffic or reputation-sensitive surface may warrant escalating earlier than stage
alone requires — a judgment call at intake, recorded in that surface's own strategy doc.

| Stage | Minimum |
|---|---|
| R&D | None — no public surface yet, or audit explicitly deferred |
| proof-sprint | Baseline audit at `required` status only, before the surface goes live |
| productionization | Baseline audit at `required` + `recommended`; audit date recorded per surface |
| maintenance | Delta audit (`get_changes`) each sprint planning cycle; regressions block release |

## When to Audit

- **Baseline** — first pass on a surface going public: `get_checklist({status:
  "required"})`, walk through in order, escalate to `recommended` as context permits.
- **Delta** — repeat visits to an already-audited surface: `get_changes({since: <last
  audit date>})` — re-check only what moved, especially status promotions that flip a
  previously-passing item to failing.
- Pair with an MDN MCP if available: this spec answers *what* and *if required*; MDN
  answers *how* and browser support.

## Init Questionnaire Trigger

"Does this project have any web-facing surface (public site, public app, or
internal/admin web UI)?"

- **No** → don't scaffold. Record the decision explicitly instead of leaving it silent —
  add a line under `docs/project/context.md`'s Dimension Applicability section: `Web Spec
  Compliance: N/A — no web-facing component (decided YYYY-MM-DD)`.
- **Yes, one surface** (or one multitenant surface with a single audience) → scaffold
  `docs/product/strategy/web-spec-compliance.md`.
- **Yes, multiple heterogeneous surfaces** → scaffold one
  `docs/product/strategy/web-spec-compliance-<surface-slug>.md` per surface — each states
  its own audience tier, applicable category subset (table above), target queries/content
  model where the audience tier makes them applicable, and audit history.

## Template

`docs/product/strategy/web-spec-compliance*.md` — scaffolded by `init` per web-facing
surface identified above.

## Interaction with Other Dimensions

Analytics and this dimension interact at the discovery layer: analytics measures whether
SEO/GEO/AEO investment is landing (organic traffic, AI-referral traffic) — public
surfaces only.

Progressive Delivery interacts when a flagged feature changes page structure, rendering,
or headers — the unflagged (crawlable/auditable) version must still pass.
