---
name: adversarial-code-review
description: Launch exactly one fresh, capability-read-only reviewer against a pinned repository diff and return a validated GitHub create-review request without submitting it.
---

# Adversarial code review

Use this skill from an engineer or another forge-authorized caller. It launches
one independent `code-reviewer` by default. It does not fan out, submit the
result, or grant the reviewer forge access. Additional reviewers or a different
model require an explicit caller request and a separate invocation.

Prepare two files: review instructions and the issue requirements/acceptance
criteria. Ensure the requested base and head commits are present locally, then
run:

```bash
bash skills/adversarial-code-review/scripts/adversarial-code-review.sh \
  --base origin/main \
  --head HEAD \
  --instructions-file /absolute/path/to/review-instructions.md \
  --requirements-file /absolute/path/to/requirements.md \
  --output /absolute/path/to/review-request.json
```

The launcher resolves immutable base and head SHAs, captures the repository,
changed files, and exact diff, and supplies the complete packet to one fresh
`outfitter run code-reviewer` process. The reviewer receives the full working
repository as its working directory and the pinned diff in its prompt, so it
needs no shell. The launcher removes common forge credentials from the child
environment.

After the process exits, the launcher validates the JSON shape, pinned head
SHA, verdict/comment relationship, comment format, and every `RIGHT`-side
anchor against the exact diff. It writes the output atomically only after all
checks pass. A nonzero exit or invalid result produces no output artifact.

The reviewer boundary is capability-read-only: its allowlist has only `read`,
`grep`, `find`, and `ls`, with no Bash, edit/write tools, or MCP server. This is
not an operating-system filesystem sandbox. Do not describe it as one. Portable
noninteractive sessions, ephemeral state, read-only filesystems, and adapter-
strict output schemas remain dependent on Outfitter execution controls; never
silently substitute prompt text for those controls.

The resulting document is only a request body for GitHub's create-review API.
Submission is a separate action by a caller that holds explicit forge-write and
approval authority.
