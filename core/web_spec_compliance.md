---
loads_when: intake, design, or review for a web-facing project — SEO, GEO/agent-readiness, accessibility, security, performance, privacy, resilience, i18n audit
size: 44 lines
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

Foundations, SEO, Accessibility, Security, Well-Known URIs, Agent Readiness (= GEO —
llms.txt, structured data for agents, MCP/A2A/Agent Skills discovery), Performance,
Privacy, Resilience, Internationalisation.

This supersedes shmorch's former `seo_geo.md` — SEO and GEO were 2 of these 10
categories, and more thoroughly sourced here than a hand-written doctrine file could stay.
`observability.md`, `analytics.md`, and `progressive_delivery.md` remain separate
dimensions — system health, user behavior, and release process aren't in this spec's scope.

## When to Audit

- **Baseline** — first pass on a project going public: `get_checklist({status:
  "required"})`, walk through in order, escalate to `recommended` as context permits.
- **Delta** — repeat visits to an already-audited project: `get_changes({since: <last
  audit date>})` — re-check only what moved, especially status promotions that flip a
  previously-passing item to failing.
- Pair with an MDN MCP if available: this spec answers *what* and *if required*; MDN
  answers *how* and browser support.

## Init Questionnaire Trigger

"Is this a public-facing web product?" → yes → scaffold
`docs/product/strategy/web-spec-compliance.md` with target queries, content model, and
GEO/trust-signal content strategy (product-specific, not covered by the spec), plus the
last audit date and any accepted deviations.

## Template

`docs/product/strategy/web-spec-compliance.md` — scaffolded by `init` for web-facing
projects.

## Interaction with Other Dimensions

Analytics and this dimension interact at the discovery layer: analytics measures whether
SEO/Agent-Readiness investment is landing (organic traffic, AI-referral traffic).

Progressive Delivery interacts when a flagged feature changes page structure, rendering,
or headers — the unflagged (crawlable/auditable) version must still pass.
