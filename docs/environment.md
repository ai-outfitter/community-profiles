# Environment fragments

Environment text lives in `prompts/environment.*.md`. Runnable profiles append
the fragments that describe their runtime. The catalog does not provide
`environment` agent profiles.

```yaml
---
name: software-development
description: Agent for implementation work.
append_system_prompt:
  - file: prompts/environment.repo-auth.md
  - file: prompts/environment.repos.md
---
```

This direct composition keeps the complete runtime context visible in each
runnable profile. An organization catalog can vendor a fragment at the same
path when its runtime cannot layer this catalog directly. The organization
MUST keep a vendored fragment byte-identical or replace it as an explicit
organization policy.

The catalog's `environment.repo-auth` fragment uses HTTPS and the credential
that the harness supplies. An organization that uses SSH SHOULD provide a
different fragment and update each consumer's append list. The organization
MUST keep credentials out of the catalog.

Environment fragments contain no credentials or consumer-specific values.
Keep project instructions in the repository's `AGENTS.md`. Do not copy an
environment fragment into that file.

## Profile taxonomy

A profile is either a runnable agent or an abstract capability profile.

An abstract profile declares `abstract: true`. It MUST NOT run directly. It
MUST NOT be the `default_agent`. Abstract profiles carry reusable capabilities
such as tools, skills, MCP servers, extensions, or models. They do not exist
only to append environment text.

The `git-forge-delegator` profile is an abstract practice profile. The
`agent-operator-resident` profile is an abstract resident contract. All other
profiles are runnable.

Inheritance composes capabilities. It MUST NOT represent an organization
chart. `append_system_prompt` composes environment and practice text.

## Role family

The catalog provides five independent role profiles: `founder`, `planner`,
`engineer`, `researcher`, and `explorer`. Their profile files define their
responsibilities.

A project MAY document that the planner reports to the founder. A project MAY
also document that the engineer, researcher, and explorer report to the
planner. These reporting lines do not change profile resolution or runtime
authority. See [Scaling by composition](scaling-by-composition.md) for the
delegation model.

The engineer and product marketer append the repository authentication and
layout fragments. The researcher does not select a runtime environment. A
caller MAY append suitable environment text when it launches the researcher.

## Kubernetes residents

The `environment.agent-operator-pod` fragment describes namespace scope,
persistent storage, task delivery, and resource limits. The `luce` profile
appends this fragment. Another Kubernetes resident SHOULD append the same
fragment and select only the capabilities that its runtime provides.

An organization catalog MAY vendor
`prompts/environment.agent-operator-pod.md`. Remove the vendored copy when the
runtime supports direct catalog layers.

## Ephemeral CI runners

The `environment.actions-runner` fragment is for agents that
ai-outfitter/actions launches on a GitHub or Forgejo runner. The repository
already exists in the working directory. The workstation `~/repos` layout does
not apply.

The `actions-agent` profile appends this fragment directly. A GitHub-specific
runner MAY also append `environment.repo-auth.md` when it needs the default
GitHub CLI and Git transport policy.

## Confined read-only exploration

The `explorer` profile denies `bash`, `write`, and `edit`. This frontmatter is
the enforceable capability boundary. Prompt text cannot enforce that boundary.

The explorer's deny list cannot be restored through inheritance. The intended
runtime has a read-only workspace, a writable `/tmp` directory, and only the
required network access.

The researcher does not use this boundary. A researcher can write durable
research notes, persona documents, and review reports. Use the explorer when a
task MUST only inspect data.
