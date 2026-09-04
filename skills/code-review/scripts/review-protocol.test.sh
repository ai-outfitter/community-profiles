#!/usr/bin/env bash
set -euo pipefail

skill_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

node --input-type=module - "$skill_dir" <<'EOF'
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const skill = fs.readFileSync(path.join(root, "SKILL.md"), "utf8");
const lens = fs.readFileSync(path.join(root, "references/simplify.md"), "utf8");
const genericSchema = JSON.parse(fs.readFileSync(path.join(root, "assets/github-review.schema.json"), "utf8"));
const simplifySchema = JSON.parse(fs.readFileSync(path.join(root, "assets/simplify-review.schema.json"), "utf8"));

const match = skill.match(/<!-- code-review-protocol:start -->\s*```json\s*([\s\S]*?)\s*```\s*<!-- code-review-protocol:end -->/);
if (!match) throw new Error("missing machine-readable code-review protocol block");
const protocol = JSON.parse(match[1]);

const expected = {
  lensAttemptsPerInvocation: 2,
  formalReviewsPerPullRequestHead: 1,
  incompleteTransport: "in-session-only",
  incompletePrefix: "Verdict: incomplete;",
  incompleteBlocksMerge: true,
  incompleteSeverityPolicy: "compute-before-status-no-downgrade",
  preserveHealthyLensFindings: true,
  simplifyEvidenceUnit: "changed-file-and-diff-hunk",
  simplifyHunkIdentifier: "path-plus-coordinate-prefix",
  inlineFindingLimit: 10,
  overflowFindingTransport: "review-body",
  incompleteMergeBlockOwner: "invoker-or-workflow",
  localAndBranchTransport: "in-session-only",
};
if (JSON.stringify(protocol) !== JSON.stringify(expected)) {
  throw new Error(`unexpected protocol contract: ${JSON.stringify(protocol)}`);
}

for (const recursiveInstruction of ["Start a few", 'agent: "delegate"', "subagents of your own"]) {
  if (lens.includes(recursiveInstruction)) throw new Error(`recursive simplify instruction returned: ${recursiveInstruction}`);
}

if (!/MUST[\s\S]{0,120}for every\s+expected region/i.test(lens)) {
  throw new Error("simplify lens does not require complete expected-region coverage");
}
if (!/do not\s+combine\s+regions/i.test(lens)) throw new Error("simplify lens permits ambiguous combined evidence");

const genericKeys = Object.keys(genericSchema.properties).sort();
const simplifyKeys = Object.keys(simplifySchema.properties).sort();
if (JSON.stringify(genericKeys) !== JSON.stringify(simplifyKeys)) throw new Error("simplify envelope shape drifted from generic review envelope");
if (JSON.stringify(genericSchema.required) !== JSON.stringify(simplifySchema.required)) throw new Error("simplify required fields drifted from generic review envelope");
for (const property of ["commit_id", "event", "comments"]) {
  if (JSON.stringify(genericSchema.properties[property]) !== JSON.stringify(simplifySchema.properties[property])) {
    throw new Error(`simplify ${property} contract drifted from generic review envelope`);
  }
}

const evidencePattern = new RegExp(simplifySchema.properties.body.pattern, "m");
const validBody = "Verdict: clean.\nSimplify evidence: src/a.js @@ -1 +1 @@ — direct return.";
const incompleteBody = "Verdict: incomplete; simplify lens did not complete.";
const invalidBody = "Verdict: clean. Inspected src/a.js.";
if (!evidencePattern.test(validBody)) throw new Error("simplify schema rejects evidence marker");
if (!evidencePattern.test(incompleteBody)) throw new Error("simplify schema rejects honest incomplete body");
if (evidencePattern.test(invalidBody)) throw new Error("simplify schema accepts evidence-free body");
if (protocol.inlineFindingLimit !== genericSchema.properties.comments.maxItems) {
  throw new Error("inline finding limit drifted from review schema");
}

console.log("review content/protocol contract: pass");
EOF
