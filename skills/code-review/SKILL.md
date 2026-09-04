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

One formal review per pull request revision. You carry both roles:

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
linked issue, and the merged envelope is delivered in-session. Formal
submission and the per-head review limit below belong to pull requests
alone.

## Protocol contract

This is a content and execution protocol for the reviewing agent, not
runtime enforcement by Outfitter. The structured-output schema enforces
the envelope shape and the simplify evidence marker; the parent must still
cross-check evidence coverage and apply the limits.

<!-- code-review-protocol:start -->
```json
{
  "lensAttemptsPerInvocation": 2,
  "formalReviewsPerPullRequestHead": 1,
  "formalReviewTransport": "github-mcp-only",
  "formalReviewTransaction": "create-add-comments-submit-verify",
  "formalReviewFallback": "in-session-incomplete",
  "ambiguousWritePolicy": "reconcile-cleanup-no-blind-retry",
  "incompleteTransport": "in-session-only",
  "incompletePrefix": "Verdict: incomplete;",
  "incompleteBlocksMerge": true,
  "incompleteSeverityPolicy": "compute-before-status-no-downgrade",
  "preserveHealthyLensFindings": true,
  "simplifyEvidenceUnit": "changed-file-and-diff-hunk",
  "simplifyHunkIdentifier": "path-plus-coordinate-prefix",
  "inlineFindingLimit": 10,
  "overflowFindingTransport": "review-body",
  "incompleteMergeBlockOwner": "invoker-or-workflow",
  "localAndBranchTransport": "in-session-only"
}
```
<!-- code-review-protocol:end -->

## Process

1. Gather: the pull request, its full diff, check results, the linked
   issue, and the existing reviews and inline threads. The issue's
   acceptance criteria are the review standard; derive them from the
   issue text and state them in the review body when none exist. For the
   simplify lens, enumerate every changed file and diff hunk. A text
   hunk's canonical identifier is `path @@ -a[,b] +c[,d] @@`: use only
   the coordinate prefix and ignore trailing section text. A binary,
   mode-only, or rename-only file is one region named with that change
   type.
2. For a pull request, a formal review already submitted on this exact head
   ends the run; report it instead of duplicating it. Prior review findings
   and unresolved inline threads enter the finding set.
3. Spawn one subagent per lens prompt under [`references/`](references/)
   — **criteria**, **correctness**, **checks**, and **simplify** — with the
   harness's subagent tool, each on the prompt below and nothing from your
   conversation. The subagent reads its lens file and gathers the pull
   request through the MCP itself; its final message is its envelope.
   Retain each valid envelope as soon as it returns.
4. A failed or schema-invalid lens gets exactly one retry in a fresh
   context with the same prompt plus one line naming the first attempt's
   failure. For simplify, missing or non-covering evidence also triggers
   this one retry, naming the missing regions. A simplify envelope whose
   body begins `Verdict: incomplete; ` is an honest schema-valid failed
   attempt and gets the same one retry. Do not retry a healthy lens, and
   never make a third attempt in the same invocation.
5. Cross-check each simplify `Simplify evidence:` line against the full
   diff gathered in step 1. Every changed file and every canonical hunk
   identifier MUST appear once; every binary, mode-only, or rename-only
   region MUST appear once. Ignore trailing hunk section text during this
   comparison. Extra or invented regions make the envelope invalid. Marker
   presence alone is insufficient.
6. Merge all healthy envelopes and all unresolved findings from prior
   reviews on this head. An incomplete lens MUST NOT erase a healthy
   lens's finding or reduce its severity. Dedup repeated findings without
   dropping them: retain the original inline comment and cite it in the
   merged body rather than reposting it. Compute the effective verdict
   from the complete finding set before adding incomplete status. The
   schema permits at most ten inline comments; when more than ten findings
   survive, keep the ten highest-severity findings inline and write every
   overflow finding in the review body with its severity, path, line, and
   full message. Overflow findings still determine the effective verdict.
7. After the one retry, a failed, missing, invalid, or evidence-free lens
   makes the merged in-session envelope incomplete. Its body starts `Verdict:
   incomplete; <lens> lens did not complete after one retry.` and then
   states the effective verdict and highest surviving severity. Preserve
   all healthy-lens comments. Use `REQUEST_CHANGES` when P0-P2 findings
   survive and `COMMENT` otherwise. This envelope is returned only
   in-session as specified in step 8; it is never submitted to GitHub.
   An incomplete result always blocks merge, including when no code
   finding survives.
8. Submit the one formal pull-request review only when every lens is
   complete, and only through the configured GitHub MCP. In Pi, use the
   directly exposed GitHub MCP review tools when present; otherwise use the
   `mcp` proxy to discover and call `pull_request_review_write` and
   `add_comment_to_pending_review`. Do not use `gh`, `curl`, or a raw GitHub
   API request as a transport fallback. Map the merged REST-shaped envelope
   to the MCP transaction exactly:

   a. Call `get_me`, then `pull_request_read` with `method: "get_reviews"`.
      If the current viewer already has a pending review on this pull request,
      fail closed without any write; this invocation does not own that review.
      Otherwise call `pull_request_review_write` with `method: "create"`, the
      repository coordinates, and `commitID` set from the envelope's
      `commit_id`. Omit `event` so this creates a pending review. Treat the
      pending review as owned by this invocation only after the create call
      returns its positive success result.
   b. For each envelope comment, call `add_comment_to_pending_review` with
      the repository coordinates, `subjectType: "LINE"`, and its `path`,
      `line`, `side`, and `body`. A line comment MUST target a changed diff
      line; a finding without one belongs in the review body.
   c. Call `pull_request_review_write` with `method: "submit_pending"`, the
      repository coordinates, and the envelope's `body` and `event`.
   d. Read the reviews and review comments back through
      `pull_request_read`. The exact-head review and every intended inline
      comment MUST be present before reporting successful delivery.

   A read-only MCP call may be retried once. A failed or ambiguous write MUST
   NOT be repeated blindly. First reconcile through `pull_request_read`: if
   the exact-head formal review exists, verify it and stop. If `create` did
   not return its positive success result, ownership is unknown: do not call
   `delete_pending`; return an incomplete report and leave any pending review
   for explicit operator reconciliation. After an acknowledged create, this
   invocation owns the pending review. If a later add or submit fails and no
   exact-head formal review exists, call `pull_request_review_write` once with
   `method: "delete_pending"` to remove only that owned partial transaction.
   Whether cleanup succeeds or reports no pending review, return an incomplete
   merged report in-session and block merge; a later invocation may try again
   from a known state. If the MCP route is absent, verification fails, or any
   lens remains incomplete, submit no alternative GitHub review or comment
   and apply that same fail-closed result.
   A later invocation may rerun normally because no review slot was
   consumed. Uncommitted and branch reviews always return their complete or
   incomplete merged envelope in-session and never submit to GitHub. Every
   invocation still gets only two attempts per failed lens. Because an
   incomplete result creates no GitHub review or status, the invoker or
   enclosing workflow MUST carry and enforce the merge block.
9. As author, act on a complete verdict: fix each blocking finding, push,
   and review the new revision. Report a clean verdict to the human who
   merges. An incomplete verdict MUST be reported as a workflow failure,
   never as a clean review or authority to merge.

## Review envelope

Every envelope is shaped as the request body for
`POST /repos/{owner}/{repo}/pulls/{n}/reviews`. Criteria, correctness,
checks, and merged envelopes validate against
[`assets/github-review.schema.json`](assets/github-review.schema.json).
The simplify envelope validates against its stricter schema named below.
The schemas' `description` fields carry the semantics.

## Subagent prompt

Each [`references/<lens>.md`](references/) is a complete subagent
instruction. Spawn criteria, correctness, and checks with
[`assets/github-review.schema.json`](assets/github-review.schema.json).
Spawn simplify with
[`assets/simplify-review.schema.json`](assets/simplify-review.schema.json),
which additionally requires at least one evidence marker. Use this base
prompt:

```text
Read <skill dir>/references/<lens>.md and follow it.
Target: pull request #<n> in <owner>/<repo>, head <sha>.
Already raised: <one line per prior finding, or none>.
```

Append this line to the simplify prompt, using the regions gathered from
the actual diff rather than the lens's output:

```text
Expected changed regions: <path plus canonical @@ coordinate prefix, or typed non-text region; one per line>.
```

Where the subagent tool takes no output schema, append one line naming the
applicable schema: "Your final message is one JSON object validating
against <schema path> — read it first."

## Transport

Submit the merged envelope to a pull request through the GitHub MCP, or
return the JSON directly to the parent agent. A missing or failed GitHub MCP
transport is an incomplete review, never permission to substitute another
GitHub client.

This is a behavioral contract, not a shell sandbox. A broad authoring profile
may still possess other GitHub clients. Live rehearsal MUST verify transport
compliance; deployments that need technical enforcement SHOULD use a dedicated
reviewer carrier whose runtime exposes only the approved MCP write path.

Whether a clean verdict may become an `APPROVE`, and who merges, is
organization policy composed from the org's fragments — never assumed
here. Without an explicit grant, a clean verdict is a `COMMENT` review
and a human approves and merges.

## Hard limits

- At most two lens attempts per invocation: the initial attempt and one
  fresh-context retry.
- At most one formal review per pull request head, submitted only after all
  lenses complete.
- An incomplete invocation submits no GitHub review or comment and stops;
  it never starts another invocation itself.
- During a review, submit only review comments and the one verdict —
  never edits to the pull request's metadata.
- Push fixes only to your own pull request, after its review is
  submitted.
