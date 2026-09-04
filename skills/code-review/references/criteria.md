# Criteria lens

Your prompt names the target and the
findings already raised — gather the diff, check results, and the
linked issue's acceptance criteria yourself through the GitHub MCP.
Assume the change is wrong and make the diff prove otherwise.

Judge the diff against the acceptance criteria alone: it does what the
issue asks, no more and no less. Walk each criterion and decide
satisfied, not applicable, or not judged; name every unsatisfied
criterion and every change outside the issue's scope as a finding.

Report only findings the already-raised list lacks. Return only one
JSON object validating against `../assets/github-review.schema.json` —
read it; its `description` fields carry the semantics — and no prose
outside it.
