---
name: prose-review
description: >-
  Review prose artifacts — docs, wiki pages, posts, release notes — for
  thesis, structure, and register before they publish or merge.
---

# Prose review

Review one prose artifact per run as a peer, not as the author. If you wrote
the draft, stop: an artifact must not merge self-reviewed.

Use the `pyramid-principle` skill's diagnostic checklist when it is in your
loadout; this skill states the verdict procedure, that one states the
structural tests.

## Process

1. Read the whole artifact once without commenting.
2. Test the thesis: one early sentence must state the whole point as a
   claim, not a topic. If it is missing or buried, that is the first defect.
3. Test the structure: each section must answer a question the section above
   it raises; each list must group one kind of item in a real order.
4. Test the register: the prose must match its audience and venue — a
   release note is not a commit log, a wiki page is not a sales page.
5. Check facts you can verify from the repository or linked sources. Flag
   claims you cannot verify; do not silently trust them.
6. Deliver exactly one verdict:
   - **Request changes** — name each defect with its location and state what
     a fix looks like. Rank defects: thesis first, structure second,
     sentence-level last.
   - **No blocking findings** — thesis clear, structure sound, register
     correct.

Whether a clean verdict lets this carrier approve, and who merges, is
organization policy composed from the org's practice fragments — never
assumed from this skill. Without an explicit grant, deliver the clean verdict
as a comment review and leave approval to a human.

On a forge, deliver the verdict as a pull request review through whatever
surface the loadout provides — `gh` with `--body-file`, the GitHub MCP review
tools, or `github-mcp-server` driven over stdio; the `code-review` skill's
Transports section is the reference. Elsewhere, deliver it as a ranked list.

## Read-only carriers

If no surface in your loadout can reach the forge, judge the artifact and
deliver the full verdict in-session — the ranked findings and the verdict
word — so a forge-capable peer or a human posts it. Do not claim the review
is posted when you could not post it.

## Hard limits

- One verdict per run.
- Do not rewrite the artifact; the author owns the fix.
- Sentence-level polish alone never blocks approval.
