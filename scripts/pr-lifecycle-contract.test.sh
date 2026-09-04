#!/usr/bin/env bash
set -euo pipefail

catalog_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

node --input-type=module - "$catalog_root" <<'EOF'
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const prompt = fs.readFileSync(path.join(root, "prompts/practice.draft-pr-lifecycle.md"), "utf8");
const match = prompt.match(/<!-- ci-wait-protocol:start -->\s*```json\s*([\s\S]*?)\s*```\s*<!-- ci-wait-protocol:end -->/);
if (!match) throw new Error("missing machine-readable CI wait protocol block");

const actual = JSON.parse(match[1]);
const expected = {
  registrationPollSeconds: 5,
  registrationTimeoutSeconds: 120,
  noChecksReportedState: "registration-pending",
  noChecksReportedIsTerminal: false,
  readyRequiresObservedChecks: true,
  readyRequiresGreenChecks: true,
};
if (JSON.stringify(actual) !== JSON.stringify(expected)) {
  throw new Error(`unexpected CI wait protocol: ${JSON.stringify(actual)}`);
}

const normalized = prompt.replace(/\s+/g, " ");
for (const required of [
  "not a terminal result",
  "every five seconds for up to two minutes",
  "until at least one check is listed",
  "leave the pull request draft and report the workflow incomplete",
  "Never report completion while the pull request is draft or CI has not been observed green",
]) {
  if (!normalized.includes(required)) throw new Error(`CI lifecycle instruction missing: ${required}`);
}

console.log("pull-request CI lifecycle contract: pass");
EOF
