---
name: code-review
description: >-
  Adversarial pull request review: cold-context subagents return findings
  as JSON, the parent submits one formal verdict, the author fixes.
---

# Code review

One review per pull request revision. You carry both roles:

- **Author** — your pull request is ready (draft cleared, checks green) and
  nothing routes a reviewer: run the review yourself, then fix what it
  finds.
- **Reviewer** — a review request names a pull request: run the review on
  it.

In both roles the judgment comes from cold-context subagents; you
aggregate their findings and submit one formal review. This one procedure
covers a local session, a resident reviewer, and an actions carrier.

## Process

1. Gather the material: the pull request, its full diff, its check
   results, and the linked issue. The issue's acceptance criteria are the
   review standard; when none exist, derive them from the issue text and
   state them in the review body.
2. Spawn one subagent per lens — at minimum **criteria** (does the diff do
   what the issue asks, no more and no less), **correctness** (broken
   invariants, missing error handling, untested behavior, security
   boundaries), and **checks** (a red check blocks) — each from the
   template below with the material inlined. A subagent gets a cold
   context: the filled template and nothing from your conversation. Use
   the harness's subagent tool; without one, run each template as its own
   print-mode session and read its final message.
3. Aggregate: merge the findings, drop duplicates, rank by severity.
   Discard a finding the diff disproves — you own the verdict, the
   subagents inform it.
4. Submit exactly one formal review (transports below): one inline comment
   per finding at its real path and line, then `REQUEST_CHANGES` when any
   finding blocks, else `COMMENT` stating which criteria are satisfied,
   which are not applicable, and which you could not judge.
5. As author, act on the verdict: fix each blocking finding, push, and
   review the new revision. Report a clean verdict to the human who
   merges.

## Subagent template

```text
Review pull request #<n> in <owner>/<repo> through the <lens> lens only.
You have no prior context; judge only the material below. Assume the
change is wrong and make the diff prove otherwise.

Acceptance criteria:
<criteria>

Diff:
<diff>

Check results:
<checks>

Return only JSON matching this schema — no prose outside it. Use real
paths and line numbers from the diff. `blocking: true` for a defect that
must be fixed before merge; `body` states the defect and what passing
looks like.

{
  "verdict": "request_changes | comment",
  "summary": "<verdict and ranked findings, one paragraph>",
  "findings": [
    { "path": "<file>", "line": <int>, "side": "RIGHT",
      "blocking": <bool>, "body": "<defect; what passing looks like>" }
  ]
}
```

The finding fields map one-to-one onto the MCP review-comment call, so
aggregation is concatenation, dedup, and rank — no reshaping.

## Transports

- **GitHub MCP** — `pull_request_read` and `issue_read` gather;
  `pull_request_review_write` `method: create` (no `event`) opens the
  pending review, one `add_comment_to_pending_review` per finding
  (`path`, `subjectType: LINE`, `line`, `side`), then
  `pull_request_review_write` `method: submit_pending` with the `event`.
- **`gh`** — `gh pr view/diff/checks <n>` gather; submit with
  `gh api repos/{owner}/{repo}/pulls/<n>/reviews` passing `event`, `body`,
  and the findings as the `comments` array (body from a file, never
  inline prose in double quotes).
- **`github-mcp-server` over stdio** — the same MCP tools as JSON-RPC from
  a shell; the pending review lives in the server process, so create,
  comment, and submit share one spawned process.

If no transport reaches the forge, deliver the full verdict in-session —
ranked findings and the verdict word — for a forge-capable peer or human
to post. Never claim a review posted that you could not post.

Whether a clean verdict may become an `APPROVE`, and who merges, is
organization policy composed from the org's fragments — never assumed
here. Without an explicit grant, a clean verdict is a `COMMENT` review and
a human approves and merges.

## Hard limits

- One formal review per pull request revision.
- During a review, submit only review comments and the one verdict —
  never edits to the pull request's metadata.
- Push fixes only to your own pull request, after its review is
  submitted.
