# SEO / GEO — Web-Facing Projects

Two distinct layers for any project with a public URL. Both are functional requirements, not post-launch bolt-ons.

## SEO — Search Engine Optimization

Traditional search (Google, Bing). Requires:
- Correct HTML structure: `<title>`, `<meta>`, `<h1>` hierarchy, canonical URLs
- Server-side rendering — crawlers don't reliably execute JavaScript; CSR-only apps are effectively invisible
- Structured data: JSON-LD schema.org
- Core Web Vitals: LCP, CLS, INP
- Sitemap, robots.txt, mobile-first rendering

SEO gets you **ranked**.

## GEO — Generative Engine Optimization

AI-powered search (ChatGPT, Perplexity, Google AI Overviews, Claude). Requires:
- Factual, specific, citable claims — numbers and named publishers, not hedged adjectives
- Prose an LLM can extract and attribute
- Being the named primary source for domain-specific facts
- Consistent page structure across similar pages (enables LLM pattern extraction)
- Research citations that signal authority over aggregated content

GEO gets you **cited**.

## When to Plan

At intent stage. The product's URL structure, rendering strategy, and content shape are all downstream of SEO/GEO requirements. Retrofitting after launch costs 3× as much as planning upfront.

## Init Questionnaire Trigger

"Is this a public-facing web product?" → yes → scaffold `docs/product/seo-geo.md` with target queries, content model, technical requirements, and GEO content rules.

## Template

`docs/product/seo-geo.md` — scaffolded by `init` for web-facing projects.

## Interaction with Other Dimensions

Analytics and SEO/GEO interact at the discovery layer: analytics measures whether SEO/GEO is working (traffic sources, organic vs. direct). Wire discovery tracking before launching SEO/GEO optimisation so you can measure it.

Progressive Delivery and SEO/GEO interact when features affect page structure, rendering, or content — changes behind a flag must not break the unflagged (crawlable) version of the page.
