---
name: code-review
description: >-
  Review a pull request diff against its issue's acceptance criteria and
  deliver one verdict, through whatever forge surface the carrier has.
---

# Code review

Review one pull request per run as a peer, not as the author. If you authored
the change, stop: an artifact must not merge self-reviewed.

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
   - **Approve** — when no blocking finding remains and the carrier has an
     explicit approval grant, submit `APPROVE` on the current head. This also
     applies to a re-review after the same reviewer requested changes.
   - **No blocking findings** — when the carrier lacks approval authority,
     submit a comment review stating which criteria are satisfied, which are
     not applicable, and which you could not judge. State that the comment
     does not clear an earlier `CHANGES_REQUESTED` decision.

This skill defines how to review. Approval authority is organization policy,
composed into the prompt by a practice fragment and never inferred from tool
access. With that grant, a clean review MUST submit `APPROVE`; without it, a
clean review MUST submit `COMMENT`. Approval never grants merge authority.

## Transports

Use whichever forge surface the loadout provides; the review is the same
through any of them.

- **`gh`** — `gh pr view/diff/checks <n>`, then
  `gh pr review <n> --request-changes --body-file <file>` (or
  `--approve` when granted, otherwise `--comment`). Write bodies to a file
  with a quoted heredoc; never pass prose inline in double quotes.
- **GitHub MCP tools** — `pull_request_read` for the diff, then the pending
  review flow. On the consolidated surface use `pull_request_review_write`
  `method: create` (no `event`), one `add_comment_to_pending_review` per
  finding, then `pull_request_review_write` `method: submit_pending`. On the
  `pull_requests_granular` surface use `create_pull_request_review`, one
  `add_pull_request_review_comment` per finding, then
  `submit_pending_pull_request_review`. Anchor findings with `path`,
  `subjectType: LINE`, `line`, and `side: RIGHT`. Submit
  `event: REQUEST_CHANGES`, `event: APPROVE` when granted, or `event: COMMENT`
  without a grant.
- **`github-mcp-server` binary, no MCP projection** — drive the same tools
  over stdio JSON-RPC from `bash`. The pending review lives in the server
  process, so create, comment, and submit MUST share one spawned process.

If none of these can reach the forge — no `bash`, no MCP, or a read-only
surface — judge the artifact and deliver the full verdict in-session, the
ranked findings and the verdict word, so a forge-capable peer or a human
posts it. Do not claim the review is posted when you could not post it.

## Hard limits

- One verdict per run. Do not request changes and approve in the same run.
- During a review, only submit review comments and one formal verdict.
- Do not edit the pull request title, body, base branch, labels, assignees,
  milestone, draft state, merge settings, or other metadata.
- Do not push commits to the branch under review; the author owns the fix.
- Do not review your own pull request.
- Report a scope conflict instead of reviewing beyond the diff.
