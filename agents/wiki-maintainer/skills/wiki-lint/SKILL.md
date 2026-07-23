---
name: wiki-lint
description: >-
  Periodic health check of the wiki — contradictions, superseded claims,
  orphan pages, missing pages and cross-references, index/log drift — emitted
  as a report or a single reviewable PR. Use on a schedule or when asked to
  check wiki health.
---

# Wiki lint

You are auditing the wiki's health. This is a read-mostly pass: read
everything, change little, and make every change reviewable.

## What to check

Sweep every page (via `index.md`, `qmd` search when available, and grep over
`log.md`) for:

- **Contradictions** — pages asserting conflicting claims that are not already
  marked "supersedes/contradicts" with citations.
- **Stale claims** — statements a newer ingested source supersedes but that
  still read as current.
- **Orphan pages** — pages with no inbound links from any other page.
- **Missing pages** — concepts mentioned across several pages that have no
  page of their own.
- **Missing cross-references** — pages that discuss each other's subject
  without linking.
- **Index/log drift** — pages absent from `index.md`, index entries pointing
  nowhere, or wiki changes with no corresponding `log.md` entry.

## What to emit

A report, ordered by severity, each finding with the page paths and a
one-line proposed fix. Close with suggestions the checks surfaced: sources
worth ingesting next and questions the wiki is now equipped to answer.

In interactive mode, deliver the report and apply only the fixes the user
approves. In shared/headless mode, the report is the PR description and the
mechanical fixes (cross-links, index repairs, supersede markers) are the PR's
single reviewable change set — one branch, one PR, never force-pushed, never
self-merged. Contradiction resolution that requires judgment stays a finding;
lint flags it, humans (or an ingest run with a better source) resolve it.

Append one entry to `log.md`:

```markdown
## [YYYY-MM-DD] lint | <n> findings
Findings: <counts by category>. Fixes applied/PR: <ref or none>.
```

## Training signal

Lint's findings double as the scoring signal if the org later trains this
skill with [ai-outfitter/autoimprove](https://github.com/ai-outfitter/autoimprove):
bounded, gated edits on a weekly cron, output as a draft PR, never
self-merged. Falling finding counts across a stable corpus mean the schema is
improving; keep the finding format consistent so runs stay comparable.
