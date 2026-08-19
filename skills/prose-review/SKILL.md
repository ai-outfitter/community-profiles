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
   - **Approve** — thesis clear, structure sound, register correct.
   - **Request changes** — name each defect with its location and state what
     a fix looks like. Rank defects: thesis first, structure second,
     sentence-level last.

On a forge, deliver the verdict as a pull request review with `gh`, writing
the body to a file and passing `--body-file`. Elsewhere, deliver it as a
ranked list.

## Read-only carriers

If your tool surface lacks `bash` (or denies it), you cannot run `gh`. Judge
the artifact and deliver the full verdict in-session — the ranked findings
and the verdict word — so a `bash`-capable peer or a human posts it to the
forge. Do not claim the review is posted when you could not post it.

## Hard limits

- One verdict per run.
- Do not rewrite the artifact; the author owns the fix.
- Sentence-level polish alone never blocks approval.
