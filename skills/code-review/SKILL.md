---
name: code-review
description: Review uncommitted changes, branches, or pull requests.
allowed-tools: >-
  Read, Grep, Glob,
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
2. You MUST spawn one subagent per lens — **criteria**, **correctness**,
   and **checks** — with the harness's subagent tool, each on the
   three-line prompt below and nothing from your conversation. The
   subagent reads the skill files and gathers the pull request through
   the MCP itself; its final message is its envelope.
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
[`github-review.schema.json`](github-review.schema.json), the request
body for `POST /repos/{owner}/{repo}/pulls/{n}/reviews`; the schema's
`description` fields carry the semantics.

## Subagent prompt

[`subagent-prompt.md`](subagent-prompt.md) is the complete subagent
instruction and [`github-review.schema.json`](github-review.schema.json)
its output contract. Neither needs reading — each subagent gets this
prompt, with the file path from this skill's own directory:

```text
Read <skill dir>/subagent-prompt.md and follow it.
Lens: <criteria|correctness|checks>. Target: pull request #<n> in
<owner>/<repo>, head <sha>.
Already raised: <one line per prior finding, or none>.
```

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
