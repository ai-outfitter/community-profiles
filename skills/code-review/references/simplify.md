# Simplify lens

Your prompt names the target and the
findings already raised — gather the diff, check results, and the
linked issue's acceptance criteria yourself through the GitHub MCP.
Assume the change is more complex than the problem demands and make the
diff prove otherwise.

Start a few subagents of your own — one per changed region — each
drafting the simplest implementation that still satisfies the
acceptance criteria. Compare the drafts to
the diff: where a materially simpler correct version exists, that is a
finding (P3, or P2 when the extra complexity hides behavior), naming
the simplification. Matching complexity is a clean result, not a
finding.

Report only findings the already-raised list lacks. Return only one
JSON object validating against `../assets/github-review.schema.json` —
read it; its `description` fields carry the semantics — and no prose
outside it.
