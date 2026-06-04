# Feedback Systems — Architecture Pattern

↑ [Architecture](../index.md)

---

## Principle

Every Shmorch-managed project should have a feedback channel that connects public users to the maintainer's workflow. This is not a product feature — it is a first-class operational requirement. A project with no feedback path has no signal loop. A project with a high-friction feedback path (auth walls, email forms, GitHub issues) has a biased signal loop — only the most motivated users contribute.

---

## The Pattern

**Public sounding board** — a low-friction, publicly visible comment channel with smart dedup and status visibility.

```
User types insight
  → system checks for similar existing comments (fuzzy or semantic)
  → if duplicate: "3 people mentioned this — join the thread" (reduce redundancy)
  → if new: submitted with status "Noted"
  → maintainer sees it in their workflow (Zulip, Linear, GitHub Issues, etc.)
  → maintainer updates status (Noted → Acknowledged → Planned → Live / Won't fix)
  → status visible publicly (closes the loop)
```

This is not a ticket system. It is a sounding board — a semi-structured channel where user intent surfaces naturally and the maintainer can respond without the overhead of triage queues or issue templates.

---

## Scope

**Two modes — always both:**

| Mode | Context | Purpose |
|---|---|---|
| Site-wide | Footer / landing | General feedback on the product itself |
| Entity-specific | Per-feature, per-content, per-app | Insight about a specific thing in the product |

Site-wide and entity-specific are the same component and data model — differentiated by a `context` field (`'site'` or an entity slug/ID).

---

## Spam Protection — Recommended Stack

No CAPTCHA. No auth wall. No third-party verification service.

1. **Honeypot field** — hidden `<input>` bots fill in; server rejects silently
2. **IP rate limit** — configurable; 5/hour is a reasonable default for public submissions
3. **AI classifier** — Claude Haiku (or equivalent small model): "Is this spam? Is this relevant to [project domain]?" Reject if spam confidence > 0.85. Log borderline cases.
4. **Content minimum** — 10 chars minimum, 1000 chars maximum
5. **Email optional** — never required; used only for follow-up opt-in

This stack covers >95% of spam without touching legitimate users. The AI classifier is the differentiating layer — it can reject domain-irrelevant submissions that honeypot + rate-limit miss.

---

## Workflow Integration

The feedback channel is only useful if the maintainer sees it. Connect to whatever is the project's primary workflow tool:

- **Zulip (DarkBadge, Shmorch projects):** POST to `feedback` topic on each new non-spam comment
- **Linear / GitHub Issues:** create an issue with the comment body + context
- **Slack / Discord:** channel notification

The integration is fire-and-forget from the server — never blocks the user response.

For Shmorch projects specifically: `/shmorch feedback [context]` command should show recent feedback items for the current project. This command does not yet exist; add to shmorch backlog when a project first ships a feedback system.

---

## Data Model (minimal)

```sql
CREATE TABLE feedback (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  context     TEXT,            -- 'site' | entity slug/ID
  body        TEXT NOT NULL CHECK (length(body) >= 10 AND length(body) <= 1000),
  email       TEXT,
  status      TEXT NOT NULL DEFAULT 'noted',
              -- noted | acknowledged | planned | live | wont_fix
  spam_score  FLOAT,
  ip_hash     TEXT,            -- hashed for rate-limit; not stored raw
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## Dedup Strategy

**v1 — full-text search:** `tsvector` + `tsquery` against existing `noted`/`acknowledged` comments in the same context. Fast, zero dependencies, good enough for <10k comments.

**v2 — semantic search:** pgvector embeddings. Upgrade when full-text produces too many false negatives (usually >5k comments in the same context).

Show dedup suggestions after a 300ms pause while the user is typing — not on submit. This is the key UX decision: surface similarity *before* they commit, not *after*.

---

## First Reference Implementation

DarkBadge (2026-05-26) — see `docs/product/features/footer.md` in the DarkBadge project.
