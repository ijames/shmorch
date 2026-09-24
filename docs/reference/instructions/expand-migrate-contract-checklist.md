# Checklist: running a migration on the Expand / Migrate / Contract / Purge ladder

Companion to [expand-migrate-contract.html](expand-migrate-contract.html). Copy into the
track's plan and tick per migration. Doctrine: `core/progressive_delivery.md`.

**Kind** (pick one, it fixes which stages apply): [ ] schema/data · [ ] message/API shape · [ ] code path · [ ] infra/site
Purge applies only to schema/data and infra.

## 0. Spec time
- [ ] Old and new representations named; which is authoritative today?
- [ ] Migration flag named (`migration.<name>`), owner named, absent = old path (dark).
- [ ] Flip-back plan written for stage 2 (what "back" means, who does it).
- [ ] Purge gate chosen: ported-to-new, or archived/snapshotted, or past retention (which one, by when).

## 1. Expand (dark, nothing observable changes)
- [ ] New column/table/field/host exists alongside the old.
- [ ] Every write path dual-writes; old stays authoritative.
- [ ] Parity check exists that compares new against old output.
- [ ] Deployed; parity check green over a real bake period.

## 2. Migrate (flagged, reversible)
- [ ] Flag flips reads (or new messages / traffic) to the new structure.
- [ ] Old structure is still written as the safety net.
- [ ] Verified: flipping the flag back loses no data (actually tried, not assumed).
- [ ] Baked at 100% with monitoring; watcher/alerts cover the new path.

## 3. Contract (one-way, own release)
- [ ] Flag, dual-write, and old read path removed in a release separate from stage 2.
- [ ] Message/code-path kinds: old shape/branch deleted; done.
- [ ] Schema/infra kinds: old storage/host left in place, dormant/cold (not dropped).

## 4. Purge (gated, own later release; schema/data and infra only)
- [ ] Purge gate satisfied (evidence recorded: port verified, or snapshot location, or retention date passed).
- [ ] Old column/table/host dropped or wiped in its own release.
- [ ] Track closed; knowledge graduated to the destination doc.
