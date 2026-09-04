---
name: code-review
description: Review uncommitted changes, branches, or pull requests.
allowed-tools: >-
  Read, Grep, Glob, Task,
  mcp__github-write__get_me, mcp__github-write__issue_read,
  mcp__github-write__get_file_contents,
  mcp__github-write__pull_request_read,
  mcp__github-write__pull_request_review_write,
  mcp__github-write__add_comment_to_pending_review
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
2. You MUST spawn one subagent per lens prompt under
   [`references/`](references/) — **criteria**, **correctness**,
   **checks**, and **simplify** (a lens that starts subagents of its
   own) — with the harness's subagent tool, each on the three-line
   prompt below and nothing from your conversation. The subagent reads
   its lens file and gathers the pull request through the MCP itself;
   its final message is its envelope.
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

Every envelope — each subagent's and the merged review — is one JSON
object validating against
[`assets/github-review.schema.json`](assets/github-review.schema.json),
the request body for `POST /repos/{owner}/{repo}/pulls/{n}/reviews`; the
schema's `description` fields carry the semantics. A carrier with a
shell MAY check anchors mechanically:
`scripts/validate_review.py --diff pr.patch --review envelope.json`.

## Subagent prompt

Each [`references/<lens>.md`](references/) is a complete subagent
instruction. Neither it nor the schema needs reading — spawn each
subagent with the prompt below and
[`assets/github-review.schema.json`](assets/github-review.schema.json)
as its structured-output schema, so the harness enforces the envelope:

```text
Read <skill dir>/references/<lens>.md and follow it.
Target: pull request #<n> in <owner>/<repo>, head <sha>.
Already raised: <one line per prior finding, or none>.
```

Where the subagent tool takes no output schema, append one line: "Your
final message is one JSON object validating against
<skill dir>/assets/github-review.schema.json — read it first."

## Transport

Submit the merged envelope to a pull request through the GitHub MCP, or
return the JSON directly to the parent agent.

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
