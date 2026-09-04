---
name: code-review
description: >-
  Review a pull request diff against its issue's acceptance criteria and
  deliver one verdict, through whatever forge surface the carrier has — or,
  when you authored the change, start that adversarial review yourself in a
  cold-context session.
---

# Code review

Review one pull request per run as a peer, not as the author. If you authored
the change, do not review it — start its review instead (see "Starting the
review of your own change"): an artifact must not merge self-reviewed.

## Starting the review of your own change

When your pull request is ready (draft cleared, checks green) and nothing
routes a reviewer automatically — no code owners, no resident review agent —
you start the adversarial review yourself. Launch an independent reviewer
with a cold context and hand it only the pull request:

```sh
outfitter run code-review -- -p "Review pull request #<n> in <owner>/<repo> against its linked issue's acceptance criteria."
```

That session composes this same skill with the adversarial-review practice
and submits the formal review on the pull request. Then act on the verdict:
fix and push for each blocking finding and start a fresh review of the new
revision; report a clean verdict to the human who merges. Never reply to
findings from inside your own session with a review of your own.

## Process

1. Read the pull request and its full diff.
2. Read the linked issue. Its acceptance criteria are the review standard.
   If no criteria exist, derive them from the issue text and state them in
   your review.
3. Check the diff against the criteria: does the change do what the issue
   asks, no more and no less?
4. Check correctness: broken invariants, missing error handling, behavior a
   test does not cover, and security boundaries the change touches.
5. Check the checks. A red check blocks a clean verdict.
6. Deliver exactly one verdict as a formal review:
   - **Request changes** — name each defect at its file and line, and state
     what passing looks like.
   - **No blocking findings** — a comment review stating which criteria are
     satisfied, which are not applicable, and which you could not judge.

This skill defines how to review. What a clean verdict *releases* — whether
this carrier may approve, and who merges — is organization policy, composed
into the prompt from the org's context and practice fragments, never assumed
from this skill. Without an explicit grant, a clean verdict is delivered as a
comment review and a human approves and merges.

## Transports

Use whichever forge surface the loadout provides; the review is the same
through any of them.

- **`gh`** — `gh pr view/diff/checks <n>`, then
  `gh pr review <n> --request-changes --body-file <file>` (or
  `--comment`). Write bodies to a file with a quoted heredoc; never pass
  prose inline in double quotes.
- **GitHub MCP tools** — `pull_request_read` for the diff, then the pending
  review flow: `pull_request_review_write` `method: create` (no `event`),
  one `add_comment_to_pending_review` per finding (`path`,
  `subjectType: LINE`, `line`, `side: RIGHT`), then
  `pull_request_review_write` `method: submit_pending` with
  `event: REQUEST_CHANGES` or `event: COMMENT`.
- **`github-mcp-server` binary, no MCP projection** — drive the same tools
  over stdio JSON-RPC from `bash`. The pending review lives in the server
  process, so create, comment, and submit MUST share one spawned process.

If none of these can reach the forge — no `bash`, no MCP, or a read-only
surface — judge the artifact and deliver the full verdict in-session, the
ranked findings and the verdict word, so a forge-capable peer or a human
posts it. Do not claim the review is posted when you could not post it.

## Hard limits

- One verdict per run. Do not request changes and declare no blocking
  findings in the same run.
- During a review, only submit review comments and one formal verdict.
- Do not edit the pull request title, body, base branch, labels, assignees,
  milestone, draft state, merge settings, or other metadata.
- Do not push commits to the branch under review; the author owns the fix.
- Do not review your own pull request.
- Report a scope conflict instead of reviewing beyond the diff.
