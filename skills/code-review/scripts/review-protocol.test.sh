#!/usr/bin/env bash
set -euo pipefail

skill_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

node --input-type=module - "$skill_dir" <<'EOF'
import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const repositoryRoot = path.resolve(root, "../..");
const skill = fs.readFileSync(path.join(root, "SKILL.md"), "utf8");
const adversarialPractice = fs.readFileSync(path.join(repositoryRoot, "prompts/practice.adversarial-review.md"), "utf8");
const lens = fs.readFileSync(path.join(root, "references/simplify.md"), "utf8");
const genericSchema = JSON.parse(fs.readFileSync(path.join(root, "assets/github-review.schema.json"), "utf8"));
const simplifySchema = JSON.parse(fs.readFileSync(path.join(root, "assets/simplify-review.schema.json"), "utf8"));
const mcpConfig = JSON.parse(fs.readFileSync(path.join(repositoryRoot, "mcp.json"), "utf8"));

const protocol = JSON.parse(fs.readFileSync(path.join(root, "assets/code-review-protocol.json"), "utf8"));
if (!skill.includes("assets/code-review-protocol.json")) {
  throw new Error("SKILL.md does not link the protocol contract asset");
}

const expected = {
  lensAttemptsPerInvocation: 2,
  formalReviewsPerPullRequestHead: 1,
  formalReviewTransport: "github-mcp-only",
  formalReviewTransaction: "create-add-comments-submit-verify",
  formalReviewFallback: "in-session-incomplete",
  ambiguousWritePolicy: "reconcile-cleanup-no-blind-retry",
  incompleteTransport: "in-session-only",
  incompletePrefix: "Verdict: incomplete; ",
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
const expectedKeys = Object.keys(expected).sort();
if (JSON.stringify(Object.keys(protocol).sort()) !== JSON.stringify(expectedKeys)) {
  throw new Error(`unexpected protocol contract keys: ${JSON.stringify(Object.keys(protocol).sort())}`);
}
for (const key of expectedKeys) {
  if (protocol[key] !== expected[key]) {
    throw new Error(`unexpected protocol contract value for ${key}: ${JSON.stringify(protocol[key])}`);
  }
}

const requiredDirectReviewTools = [
  "get_me",
  "issue_read",
  "get_file_contents",
  "pull_request_read",
  "pull_request_review_write",
  "add_comment_to_pending_review",
];
const configuredDirectTools = mcpConfig.mcpServers?.["github-write"]?.directTools;
if (JSON.stringify(configuredDirectTools) !== JSON.stringify(requiredDirectReviewTools)) {
  throw new Error(`GitHub MCP direct review tools drifted: ${JSON.stringify(configuredDirectTools)}`);
}

if (/\bgh\s+api\s+repos\b|\bcurl\s+(?:-|https?:)/i.test(adversarialPractice)) {
  throw new Error("adversarial-review practice reintroduced a forbidden review transport");
}
const normalizedPractice = adversarialPractice.replace(/\s+/g, " ");
for (const requiredPracticeText of ["GitHub MCP transaction", "code-review", "raw API calls are not review transports"]) {
  if (!normalizedPractice.includes(requiredPracticeText)) {
    throw new Error(`adversarial-review practice omits transport contract: ${requiredPracticeText}`);
  }
}
const normalizedSkill = skill.replace(/\s+/g, " ");
for (const transactionRequirement of [
  '`get_me`',
  'method: "get_reviews"',
  'method: "create"',
  'commitID',
  'subjectType: "LINE"',
  'method: "submit_pending"',
  'method: "delete_pending"',
  'pull_request_read',
  "this invocation does not own that review",
  "only after the create call returns its positive success result",
  "do not call `delete_pending`",
  "remove only that owned partial transaction",
]) {
  if (!normalizedSkill.includes(transactionRequirement)) {
    throw new Error(`code-review skill omits MCP transaction requirement: ${transactionRequirement}`);
  }
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

const evidencePattern = new RegExp(simplifySchema.properties.body.pattern);
if (!simplifySchema.properties.body.pattern.startsWith(`^(${protocol.incompletePrefix}`)) {
  throw new Error("simplify schema pattern drifted from the protocol incomplete prefix");
}
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
