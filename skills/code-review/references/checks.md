# Checks lens

Your prompt names the target and the
findings already raised — gather the diff, check results, and the
linked issue's acceptance criteria yourself through the GitHub MCP.
Assume the change is wrong and make the diff prove otherwise.

Read every check on the reviewed head. A red or still-pending required
check blocks (P1). Judge coverage too: the acceptance criteria name
verifications — a criterion no check or test exercises is a finding.

Report only findings the already-raised list lacks. Return only one
JSON object validating against `../assets/github-review.schema.json` —
read it; its `description` fields carry the semantics — and no prose
outside it.
