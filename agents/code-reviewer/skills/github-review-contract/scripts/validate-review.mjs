#!/usr/bin/env node

import { readFileSync } from 'node:fs';

function fail(message) {
  console.error(`invalid review: ${message}`);
  process.exit(1);
}

const [reviewPath, diffPath, expectedCommit] = process.argv.slice(2);
if (!reviewPath || !diffPath || !/^[0-9a-f]{40}$/.test(expectedCommit ?? '')) {
  fail('usage: validate-review.mjs REVIEW DIFF HEAD_SHA');
}

let review;
try {
  review = JSON.parse(readFileSync(reviewPath, 'utf8'));
} catch (error) {
  fail(`review is not JSON: ${error.message}`);
}

const keys = Object.keys(review).sort().join(',');
if (keys !== 'body,comments,commit_id,event') fail('top-level fields do not match the create-review contract');
if (review.commit_id !== expectedCommit) fail('commit_id is not the pinned head SHA');
if (typeof review.body !== 'string' || review.body.trim() === '') fail('body must be a non-empty string');
if (!['APPROVE', 'REQUEST_CHANGES'].includes(review.event)) fail('event must be APPROVE or REQUEST_CHANGES');
if (!Array.isArray(review.comments)) fail('comments must be an array');
if (review.event === 'APPROVE' && review.comments.length !== 0) fail('APPROVE must not contain inline comments');
if (review.event === 'REQUEST_CHANGES' && review.comments.length === 0) fail('REQUEST_CHANGES requires a blocking inline finding');

const eligible = new Set();
let path;
let rightLine = 0;
let inHunk = false;
for (const text of readFileSync(diffPath, 'utf8').split('\n')) {
  if (text.startsWith('+++ ')) {
    const value = text.slice(4);
    path = value === '/dev/null' ? undefined : value.replace(/^b\//, '');
    inHunk = false;
    continue;
  }
  const hunk = text.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@/);
  if (hunk) {
    rightLine = Number(hunk[1]);
    inHunk = true;
    continue;
  }
  if (!inHunk || !path || text.startsWith('\\ No newline')) continue;
  if (text.startsWith('+') || text.startsWith(' ')) {
    eligible.add(`${path}:${rightLine}`);
    rightLine += 1;
  } else if (!text.startsWith('-')) {
    inHunk = false;
  }
}

const bodyPattern = /^\[P[0-2]\] .+\n\nReasoning: .+\n\nImpact: .+\n\nFix: .+/s;
for (const [index, comment] of review.comments.entries()) {
  if (!comment || typeof comment !== 'object' || Array.isArray(comment)) fail(`comments[${index}] must be an object`);
  if (Object.keys(comment).sort().join(',') !== 'body,line,path,side') fail(`comments[${index}] fields do not match the contract`);
  if (typeof comment.path !== 'string' || comment.path === '') fail(`comments[${index}].path is required`);
  if (!Number.isInteger(comment.line) || comment.line < 1) fail(`comments[${index}].line must be a positive integer`);
  if (comment.side !== 'RIGHT') fail(`comments[${index}].side must be RIGHT`);
  if (typeof comment.body !== 'string' || !bodyPattern.test(comment.body)) fail(`comments[${index}].body lacks severity, reasoning, impact, or fix`);
  if (!eligible.has(`${comment.path}:${comment.line}`)) fail(`comments[${index}] does not target a RIGHT-side line in the pinned diff`);
}

console.log('Valid GitHub create-review request.');
