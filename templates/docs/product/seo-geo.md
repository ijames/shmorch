# SEO / GEO Strategy

↑ [Product](index.md)

> Fill this in at intent stage for any public-facing web product. SEO/GEO requirements drive URL structure, rendering strategy, and content shape — plan before building, not after.
>
> **SEO** = ranked by traditional search (Google, Bing). **GEO** = cited by AI-powered search (ChatGPT, Perplexity, Google AI Overviews). SEO gets you ranked; GEO gets you cited.

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

## Technical Requirements

- [ ] Rendering: SSR or SSG on all content pages (not CSR-only)
- [ ] `<title>` and `<meta name="description">` templates per page type
- [ ] JSON-LD structured data on content pages (schema.org type appropriate to domain)
- [ ] OpenGraph + Twitter Card meta on every page
- [ ] Sitemap (`/sitemap.xml`) — auto-generated, one entry per indexable page
- [ ] `robots.txt` — allow all crawlers, point to sitemap
- [ ] Canonical URLs — no duplicate content from query params or multiple paths
- [ ] Core Web Vitals baseline (LCP, CLS, INP)

---

## GEO Content Requirements

For AI assistants to cite this product's content:

- [ ] All factual claims use specific numbers/names, not hedged adjectives
- [ ] Publisher name appears in content alongside claims (not just in the URL)
- [ ] Methodology / source explanation page exists and is linked from content pages
- [ ] Consistent structure across similar pages (enables LLM pattern extraction)
- [ ] Research citations present where appropriate (signals primary source, not aggregator)
- [ ] No claims that depend on JavaScript execution to appear in HTML

---

## Authority and Trust Signals

- (publisher / organization identity)
- (research citations or methodology transparency)
- (other trust signals relevant to this domain)
