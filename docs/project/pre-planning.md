# Pre-planning

Deferred ideas and proposals not yet ready for the active backlog.

---

## Shmorch Live Docs Structure (deferred)

Agreed minimal docs structure for shmorch's own live documentation.
Full template structure is overkill — shmorch is a tool, not a product.

```
docs/
  README.md               ← exists, keep (shmorch-specific content)
  index.md                ← what shmorch is + philosophy + tenet list
  research.md             ← explorations, open questions, things to investigate
  state/
    plan.md               ← exists, keep (backlog, in-progress, completed)
    context.md            ← identity/purpose (used by /go to orient sessions)
    session.md            ← last session summary (written by /wrap)
  architecture/
    feedback-systems.md   ← exists, keep
    decisions.md          ← permanent ADR log (why things are the way they are)
  reference/
    aws-lambda-deploy.md  ← exists, keep
```

Excluded: `product/`, `development/`, `testing/`, `guides/`, `to_review/` — not applicable to a tool project.

Status: blocked on shmorch-core.md refactor. Revisit after that lands.
