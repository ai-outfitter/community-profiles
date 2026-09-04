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
const fixtures = path.join(root, "scripts", "fixtures");

const match = skill.match(/<!-- code-review-protocol:start -->\s*```json\s*([\s\S]*?)\s*```\s*<!-- code-review-protocol:end -->/);
if (!match) throw new Error("missing machine-readable code-review protocol block");
const protocol = JSON.parse(match[1]);

const expected = {
  lensAttemptsPerInvocation: 2,
  formalReviewsPerPullRequestHead: 1,
  formalReviewTransport: "github-mcp-only",
  formalReviewTransaction: "create-add-comments-submit-verify",
  formalReviewFallback: "in-session-incomplete",
  ambiguousWritePolicy: "reconcile-cleanup-no-blind-retry",
  formalReviewReadback: ["get_reviews", "get_review_comments"],
  reviewCommentCountPolicy: "exact-post-submit-delta-including-zero",
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
  'method: "get_review_comments"',
  "pre-submit baseline",
  "mandatory even when the envelope has zero inline comments",
  "exactly one new current-viewer formal review MUST be present",
  "`COMMENT` -> `COMMENTED`",
  "exact number of new comments MUST equal `envelope.comments.length`, including zero",
  "returned `line` or `original_line`",
  "Follow pagination to completion",
  "both read-backs pass",
]) {
  if (!normalizedSkill.includes(transactionRequirement)) {
    throw new Error(`code-review skill omits MCP transaction requirement: ${transactionRequirement}`);
  }
}

const submitIndex = normalizedSkill.indexOf('method: "submit_pending"');
const postSubmitSectionIndex = normalizedSkill.indexOf('d. After submission', submitIndex);
const reviewCommentsReadbackIndex = normalizedSkill.indexOf('method: "get_review_comments"', postSubmitSectionIndex);
if (submitIndex < 0 || postSubmitSectionIndex < 0 || reviewCommentsReadbackIndex < 0) {
  throw new Error("code-review skill does not require get_review_comments after formal review submission");
}

const helperMatch = skill.match(/<!-- github-mcp-read-helper:start -->\s*```js\s*([\s\S]*?)\s*```\s*<!-- github-mcp-read-helper:end -->/);
if (!helperMatch) throw new Error("missing canonical GitHub MCP read helper");
const helperSource = `${helperMatch[1]}\nexport { decodeGitHubMcpPayload, normalizeReviewPage, normalizeReviewCommentPage, readGitHubMcpPage, readAllReviews, readAllReviewComments };`;
const helper = await import(`data:text/javascript;base64,${Buffer.from(helperSource).toString("base64")}`);
const loadFixture = (name) => JSON.parse(fs.readFileSync(path.join(fixtures, name), "utf8"));

const reviewsPage = loadFixture("get-reviews.wrapper.json");
const commentsPage = loadFixture("get-review-comments.wrapper.json");
const reviews = helper.normalizeReviewPage(helper.decodeGitHubMcpPayload(reviewsPage, "get_reviews"));
if (reviews.length !== 1 || reviews[0].id !== 5114879517) {
  throw new Error("review wrapper decoder lost the inner review array");
}
const commentPayload = helper.normalizeReviewCommentPage(helper.decodeGitHubMcpPayload(commentsPage, "get_review_comments"));
if (commentPayload.review_threads[0].comments[0].url !== "https://example.test/comment/7") {
  throw new Error("review-comment wrapper decoder lost the inner thread comments");
}
for (const fixture of [
  "declared-error.wrapper.json",
  "incomplete-comments.wrapper.json",
  "malformed-json.wrapper.json",
  "malformed-comments.wrapper.json",
]) {
  const wrapped = loadFixture(fixture);
  let rejected = false;
  try {
    const payload = helper.decodeGitHubMcpPayload(wrapped, "get_review_comments");
    helper.normalizeReviewCommentPage(payload);
  } catch {
    rejected = true;
  }
  if (!rejected) throw new Error(`${fixture} did not fail closed`);
}

const wrap = (payload) => ({
  ok: true,
  data: { content: [{ type: "text", text: JSON.stringify(payload) }] },
});
const fullReviewPage = Array.from({ length: 100 }, (_, id) => ({ id }));
const reviewCalls = [];
const reviewTools = { call: async (name, input) => {
  if (name !== "github-write_pull_request_read") throw new Error("unexpected tool");
  reviewCalls.push(input);
  return wrap(input.page === 1 ? fullReviewPage : [{ id: 100 }]);
} };
const allReviews = await helper.readAllReviews(reviewTools, { owner: "o", repo: "r", pullNumber: 1 });
if (allReviews.length !== 101 || reviewCalls.map((call) => call.page).join(",") !== "1,2") {
  throw new Error("get_reviews did not use REST short-page pagination");
}

const commentCalls = [];
const commentTools = { call: async (_name, input) => {
  commentCalls.push(input);
  if (commentCalls.length === 1) throw new Error("transient read failure");
  if (!input.after) return wrap({ review_threads: [{ comments: [{ id: 1 }], total_count: 1 }], totalCount: 2, pageInfo: { hasNextPage: true, endCursor: "cursor-1" } });
  return wrap({ review_threads: [{ comments: [{ id: 2 }], total_count: 1 }], totalCount: 2, pageInfo: { hasNextPage: false } });
} };
const allComments = await helper.readAllReviewComments(commentTools, { owner: "o", repo: "r", pullNumber: 1 });
if (allComments.map((comment) => comment.id).join(",") !== "1,2") {
  throw new Error("get_review_comments did not collect every thread comment");
}
if (commentCalls.length !== 3 || commentCalls[0].after || commentCalls[1].after || commentCalls[2].after !== "cursor-1") {
  throw new Error("get_review_comments did not retry once then use cursor pagination");
}
let readAttempts = 0;
await helper.readGitHubMcpPage({ call: async () => { readAttempts += 1; throw new Error("down"); } }, { method: "get_reviews" }, helper.normalizeReviewPage).then(
  () => { throw new Error("failed read did not reject"); },
  () => {},
);
if (readAttempts !== 2) throw new Error(`read helper attempted ${readAttempts} calls instead of two`);
if (/pull_request_review_write|add_comment_to_pending_review/.test(helperMatch[1])) {
  throw new Error("read retry helper includes a GitHub write tool");
}
const incompleteOuterPage = wrap({
  review_threads: [], totalCount: 1, pageInfo: { hasNextPage: false },
});
await helper.readAllReviewComments(
  { call: async () => incompleteOuterPage },
  { owner: "o", repo: "r", pullNumber: 1 },
).then(
  () => { throw new Error("incomplete outer thread set did not reject"); },
  () => {},
);

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
