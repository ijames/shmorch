↑ [Inbox](index.md)

# Personal-eval could ingest sources beyond Claude Code transcripts

**Issue (2026-08-13):** `pe` (personal-eval) currently sources persona evidence only
from Claude Code session transcripts (`session_turns.py` against
`~/.claude/projects/*/*.jsonl`). That's a narrow slice of how someone actually thinks
and communicates — blog posts, Google Docs, and social posts (e.g. Facebook) would add
evidence the coding-session transcripts structurally can't: values, interests, and
communication style expressed outside a coding context.

**What to consider:**
- Each new source needs its own extraction path analogous to `session_turns.py` (read
  raw content → normalized text) before `pe-summarizer` could run against it — the
  taxonomy in `profile/index.md` and the summarizer/synthesizer roles likely still
  apply unchanged, since they're already source-agnostic about *what* text they're
  handed.
- Authentication/access to blogs, Docs, Facebook, etc. is a materially different
  problem than reading local transcript files — likely needs its own connector layer,
  and raises consent/scope questions transcripts don't (should be opt-in, source by
  source).
- This is the seed of a bigger idea: personal-eval's pipeline (extract → summarize →
  synthesize → analyze against a taxonomy) might be general enough to pull out of
  shmorch as its own tool/product, independent of Claude Code specifically. Noted as a
  possible future direction, not a near-term commitment — revisit once the current
  single-source pipeline (transcript ingestion) is solid and the profile has enough
  volume to know what's actually missing from it.

**Status:** Captured, not scoped. No action needed until revisited.
