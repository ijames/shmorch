# go / resume / wrap need to become more deterministic

User observation (2026-08-14), while requesting the new light `touch` command: `go`,
`resume`, and `wrap` are all "VERY heavy" for what they do. `touch` peels off one narrow
slice (reconcile `session.md`/`plan/` against git reality, no ceremony) as a small,
deterministic sibling — but the underlying heaviness in the other three is unaddressed.

Related: `profile/03-work-activities-process.md` in the personal-profile repo already has
citations (`[^58a51e5f]`) for this same instinct showing up in a real session — proposing
deterministic routines + subagent delegation for go/resume/wrap/documentarian, validated
with a concrete token-count simulation before being treated as worth building.

Not evaluated or scoped here — just captured so `self-improve` can pick it up.
