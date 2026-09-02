#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

require() {
  local pattern=$1
  local file=$2
  if ! grep -Eq -- "$pattern" "$root/$file"; then
    printf 'missing lifecycle contract %s in %s\n' "$pattern" "$file" >&2
    exit 1
  fi
}

# The shared review procedure distinguishes every GitHub review event.
require 'APPROVE' skills/code-review/SKILL.md
require 'REQUEST_CHANGES' skills/code-review/SKILL.md
require 'COMMENT' skills/code-review/SKILL.md
require 're-review' skills/code-review/SKILL.md

# Approval is an explicit composition grant, not an inference from write tools.
require 'grants an independent reviewer authority to approve' prompts/practice.pull-request-approval.md
require 'earlier change request' prompts/practice.pull-request-approval.md
require 'Never review or approve your own pull request' prompts/practice.pull-request-approval.md
require 'practice.pull-request-approval.md' agents/code-review/agent.md
require 'practice.pull-request-approval.md' agents/luce/agent.md

# The implementer creates a fresh wake on the corrected head for the same peer.
require 'push' prompts/practice.draft-pr-lifecycle.md
require 'new head' prompts/practice.draft-pr-lifecycle.md
require 'Re-request review from the same reviewer' prompts/practice.draft-pr-lifecycle.md
require 'wake signal' prompts/practice.draft-pr-lifecycle.md
require 'never merge your own work' agents/resident-engineer/agent.md

# Luce exposes narrow draft, reviewer-request, and review tools.
require 'pull_requests_granular' agents/luce/mcp.json
require 'request_pull_request_reviewers' agents/luce/mcp.json
require 'submit_pending_pull_request_review' agents/luce/mcp.json
if grep -q '"update_pull_request"' agents/luce/mcp.json; then
  printf 'resident carrier exposes over-broad update_pull_request\n' >&2
  exit 1
fi

printf 'resident review lifecycle contract is composed\n'
