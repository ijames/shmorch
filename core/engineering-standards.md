---
loads_when: writing prose or commits, making a technical trade-off call, reproducing a bug, or running an end-to-end/QA pass
size: 35 lines
---

# Engineering Standards

General-purpose standards that apply across every project Shmorch touches - content, docs, and hands-on development alike. Adapted from Kun Chen's public engineering guidelines.

---

## Writing conventions

- Never use an em dash — or other AI-slop tells — in anything a person outside the authoring session will read: web/product content, docs, PR titles and descriptions, commit messages meant for human review — including generated content in any sibling or private data repo the project writes to, not just the repo this doctrine lives in. A project-level override may add detail; it may not narrow this scope. Use a plain dash instead. This does not extend to shmorch's own internal doctrine (`core/*.md`, `workflows/*.md`, etc.) — the em dash is the established house style there, and reflowing it would be pure churn for no reader who needs it.
- Never manually modify a file marked auto-generated (e.g. a CHANGELOG.md produced by a release tool). Edit the generator or its source, not the output.
- Never hard-wrap authored markdown prose. See `core/documentation.md` § No Hard Wrapping.

---

## Technical decision-making

Do not weight development cost heavily when choosing between technical approaches. Prefer quality, simplicity, robustness, scalability, and long-term maintainability. A cheaper-to-build option that is worse on those axes is not the tie-breaker.

---

## Bug reproduction

Before fixing a bug, reproduce it first in an end-to-end setting that matches how a real end user would trigger it, not a synthetic unit-level repro. This surfaces the actual problem, not a plausible-looking stand-in, so the fix actually solves it.

---

## QA and engineering excellence

- When end-to-end testing a product, scrutinize the UI closely. Obsess over pixel-level correctness. If something looks off, even if unrelated to the current task, get it fixed alongside the current work.
- Hold the same standard for engineering hygiene: lint errors, failing tests, flaky tests. If you see one, even if you did not cause it and it is unrelated to the current task, fix it rather than stepping around it.
