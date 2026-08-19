---
name: code-review
description: >-
  Review a pull request diff against its issue's acceptance criteria; approve,
  request changes, or merge when green via gh.
---

# Code review

Review one pull request per run as a peer, not as the author. If you authored
the change, stop: an artifact must not merge self-reviewed.

## Process

1. Read the pull request: `gh pr view <number>` and `gh pr diff <number>`.
2. Read the linked issue. Its acceptance criteria are the review standard.
   If no criteria exist, derive them from the issue text and state them in
   your review.
3. Check the diff against the criteria: does the change do what the issue
   asks, no more and no less?
4. Check correctness: broken invariants, missing error handling, behavior a
   test does not cover, and security boundaries the change touches.
5. Check the checks: `gh pr checks <number>`. A red check blocks approval.
6. Deliver exactly one verdict:
   - **Approve** — criteria met, checks green:
     `gh pr review <number> --approve --body-file <file>`.
   - **Request changes** — name each defect with file and line, and state
     what passing looks like:
     `gh pr review <number> --request-changes --body-file <file>`.
   - **Merge when green** — only when the repository's convention authorizes
     the reviewer to merge: approve, then `gh pr merge <number>`.

Write review bodies to a file with a quoted heredoc and pass `--body-file`;
never pass prose inline with `--body` in double quotes.

## Read-only carriers

If your tool surface lacks `bash` (or denies it), you cannot run `gh`. Judge
the artifact and deliver the full verdict in-session — the ranked findings
and the verdict word — so a `bash`-capable peer or a human posts it to the
forge. Do not claim the review is posted when you could not post it.

## Hard limits

- One verdict per run. Do not approve and request changes in the same run.
- Do not push commits to the branch under review; the author owns the fix.
- Report a scope conflict instead of reviewing beyond the diff.
