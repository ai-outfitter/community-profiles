---
name: code-review
description: Review uncommitted changes, branches, or pull requests.
---

# Code review

One review per pull request revision. You carry both roles:

- **Author** — your pull request is ready (draft cleared, checks green)
  and nothing routes a reviewer: run the review yourself, then fix what
  it finds.
- **Reviewer** — a review request names a pull request: run the review on
  it.

The judgment comes from cold-context subagents; you merge their envelopes
and submit one formal review. One procedure covers a local session, a
resident reviewer, and an actions carrier.

The same fan-out and merge review uncommitted changes (diff against
`HEAD`, `commit_id` is the `HEAD` sha) or a branch (diff against the merge
base, `commit_id` is the tip): the review standard is the stated intent or
linked issue, and the merged envelope is delivered in-session — formal
submission belongs to pull requests alone.

## Process

1. Gather: the pull request, its full diff, check results, the linked
   issue, and the existing reviews and inline threads. The issue's
   acceptance criteria are the review standard; derive them from the
   issue text and state them in the review body when none exist. A formal
   review already on this revision ends the run — report it instead of
   duplicating it.
2. You MUST spawn one subagent per lens — **criteria** (the diff does
   what the issue asks, no more and no less), **correctness** (broken
   invariants, missing error handling, untested behavior, security
   boundaries), and **checks** (a red check blocks) — each from the
   template below with the material inlined. A subagent gets a cold
   context: the filled template and nothing from your conversation. Use
   the harness's subagent tool; without one, write each filled template
   to a file and run it as its own print-mode session from a shell
   (`pi -p "$(cat <lens>.md)"`, `claude -p ...`, or the harness
   equivalent), reading its final message as the envelope.
3. Merge the envelopes into one: pool the comments, dedup to one finding
   per root cause — dropping any a prior review or thread already raised
   — verify each against the diff, and recompute the verdict from what
   survives. Subagent verdicts are advisory; you own the merged one.
4. Submit the merged envelope as the one formal review (transports
   below).
5. As author, act on the verdict: fix each blocking finding, push, and
   review the new revision. Report a clean verdict to the human who
   merges.

## Review envelope

Every subagent returns exactly one JSON object, and the merged review is
one more object of the same shape — the request body for
`POST /repos/{owner}/{repo}/pulls/{n}/reviews`, so submission needs no
reshaping:

```json
{
  "commit_id": "<reviewed head sha>",
  "event": "REQUEST_CHANGES | COMMENT",
  "body": "<verdict first; criteria satisfied, not applicable, not judged>",
  "comments": [
    { "path": "<file>", "line": 1, "side": "RIGHT",
      "body": "[P1] <defect; what passing looks like>" }
  ]
}
```

- Severity is the `[P0]`–`[P3]` prefix on each comment body (GitHub has
  no severity field): P0 data loss, security, outage; P1 wrong
  primary-path behavior; P2 other actionable defect; P3 non-blocking.
- `event` is `REQUEST_CHANGES` when a P0–P2 finding survives the merge,
  else `COMMENT`. GitHub rejects `REQUEST_CHANGES` and `APPROVE` from
  the pull request's own author, so a self-review submits the same
  comments as a `COMMENT` review whose body leads with the verdict it
  would otherwise carry.
- `path`, `line`, `side` anchor a comment to the diff: `RIGHT` for a new
  line, `LEFT` for a deleted one. A finding that anchors to no diff line
  goes in `body` instead of being dropped.
- Include only findings likely real and actionable, one per root cause;
  an empty `comments` array with the inspected surface stated in `body`
  is a valid clean review.

## Subagent template

```text
Review pull request #<n> in <owner>/<repo> through the <lens> lens only.
You have no prior context; judge only the material below. Assume the
change is wrong and make the diff prove otherwise. These findings were
already raised — do not repeat them:
<existing review and thread findings, or "none">

Acceptance criteria:
<criteria>

Diff (head <sha>):
<diff>

Check results:
<checks>

Return only a JSON review envelope, no prose outside it:
{ "commit_id": "<head sha>", "event": "REQUEST_CHANGES | COMMENT",
  "body": "<verdict and reasoning>",
  "comments": [ { "path": "<file from the diff>", "line": <int>,
    "side": "RIGHT|LEFT", "body": "[P0-P3] <defect; what passing looks
    like>" } ] }
```

## Transports

- **GitHub MCP** — `pull_request_read` and `issue_read` gather;
  `pull_request_review_write` `method: create` (no `event`) opens the
  pending review, one `add_comment_to_pending_review` per envelope
  comment (`path`, `subjectType: LINE`, `line`, `side`), then
  `pull_request_review_write` `method: submit_pending` with the
  envelope's `event`.
- **`gh`** — `gh pr view/diff/checks <n>` gathers; the merged envelope
  submits verbatim:
  `gh api repos/{owner}/{repo}/pulls/<n>/reviews --input envelope.json`.

If no transport reaches the forge, deliver the envelope in-session for a
forge-capable peer or human to post. Never claim a review posted that you
could not post.

Whether a clean verdict may become an `APPROVE`, and who merges, is
organization policy composed from the org's fragments — never assumed
here. Without an explicit grant, a clean verdict is a `COMMENT` review
and a human approves and merges.

## Hard limits

- One formal review per pull request revision.
- During a review, submit only review comments and the one verdict —
  never edits to the pull request's metadata.
- Push fixes only to your own pull request, after its review is
  submitted.
