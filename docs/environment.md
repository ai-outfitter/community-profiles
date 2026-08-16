# Environment baseline

The `environment` agent is a base profile for agents that need a stable
repository convention. It inherits the registered `repo-auth` agent, so a
consumer can inherit `environment` and receive both repository location and
authentication guidance.

```yaml
---
name: software-development
description: Agent for implementation work.
inherits: [environment]
---
```

The effective resource set resolves each agent slug across layers. A higher
precedence layer can replace `agents/repo-auth/agent.md` with the same `name:
repo-auth` and select a different approved Git transport. This is the override
point for a local, project, shared, or global environment; it avoids publishing
separate authentication variants that consumers must choose between.

The catalog's default `repo-auth` resource uses HTTPS and a GitHub CLI-managed
token. An environment that uses SSH can replace that resource with this compact
shape, keeping the same slug:

```yaml
---
name: repo-auth
description: Repository authentication convention for SSH environments.
---

# Repository authentication

- Git transport MUST use `git@github.com:<owner>/<repo-name>.git`.
- GitHub CLI authentication MUST remain available for API operations.
- Private keys and credentials MUST NOT appear in files, prompts, arguments, or logs.
```

The baseline contains no credentials or consumer-specific values. Keep project
instructions in the repository's `AGENTS.md`; do not copy this environment
policy into that project-owned file.

## Profile taxonomy

A profile is either a **runnable agent** or an **abstract composable**.

An abstract profile declares `abstract: true`. It exists to be inherited and
MUST NOT be run directly or named as `default_agent`. The catalog's abstract
profiles are the environments — `repo-auth`, `environment`,
`agent-operator-pod`, `actions-runner`, `container-readonly` — and the
`git-forge-delegator` practice. Everything else is runnable: `founder`,
`planner`, `engineer`, `researcher`, `explorer`, `actions-agent`,
`grafana-agent`, `media-editor`, `persona-reviewer`, and `platform`.

Two kinds of abstract profile compose differently:

- An **environment** describes where an agent runs and the tool policy that
  runtime enforces. An agent takes one runtime environment.
- A **practice** describes how an agent works, independent of where. An agent
  MAY take several.

`abstract: true` is metadata that older Outfitter releases ignore, because the
agent schema accepts additional properties. Marking a profile abstract is
therefore safe for every consumer today; enforcement — refusing an abstract
slug as a run target or `default_agent` — arrives with the Outfitter release
that reads the field.

Whether abstract profiles should also carry a namespace prefix in their slug
(`environment.repo-auth`) is deliberately deferred: dot-separated slugs need
an Outfitter release that accepts the pattern
([outfitter#302](https://github.com/ai-outfitter/outfitter/pull/302)), while
`abstract: true` needs nothing.

## Role family

The catalog provides five independent role profiles: `founder`, `planner`,
`engineer`, `researcher`, and `explorer`. Their profile files define their
responsibilities.

A project MAY document that the planner reports to the founder. A project MAY
also document that the engineer, researcher, and explorer report to the
planner. These reporting lines are documentation only. They do not change
profile resolution or runtime authority. See
[Scaling by composition](scaling-by-composition.md) for the delegation model
and the growth path.

Inheritance represents capability composition only. Inheritance MUST NOT
represent an organization chart. The role profiles do not inherit other role
profiles. The engineer inherits `environment` for repository conventions. The
researcher and explorer inherit `container-readonly` for the
read-only tool boundary.

## Kubernetes residents

The `agent-operator-pod` profile extends the baseline for Kubernetes residents.
It inherits `environment`, which supplies the repository and authentication
rules. The profile also supplies the pod runtime context: namespace scope,
persistent workspace, durable task re-offers, resource limits, the Chrome
sidecar, and operator-provisioned credentials:

```yaml
---
name: resident
inherits: [agent-operator-pod]
---
```

An organization catalog MAY vendor `agents/agent-operator-pod/`,
`agents/environment/`, and `agents/repo-auth/` when its runtime cannot layer
this catalog directly. The same-slug override rule still applies. An
organization can replace `repo-auth` to select another forge or transport.
Remove the vendored copies when the runtime supports direct catalog layers.

## Ephemeral CI runners

The `actions-runner` agent is the environment for agents that
ai-outfitter/actions launches on a GitHub or Forgejo runner. It is forge-neutral
and does **not** inherit `environment`: the repository is already checked out
at the working directory, so the workstation `~/repos` layout does not apply.
It states the runner realities: a temporary workspace, a hard timeout, an audit
transcript, forge-posted user-facing results, and label-based routing.
`actions-agent` inherits it. A GitHub-specific child MAY inherit `repo-auth`.

## Confined read-only research

The `container-readonly` agent is the environment for read-only research and
exploration in a locked-down container. It denies `bash`, `write`, and `edit`.
Inherited deny lists combine, so a child profile cannot restore these tools.
The intended runtime has a read-only workspace, a writable `/tmp`, and only the
network access that research requires. The image variant ships separately.

The `researcher` and `explorer` profiles inherit `container-readonly`. The
The `planner` profile does not inherit it. Its allowlist contains only read and
research tools. It denies file-mutation tools, and it delegates bounded work to
the engineer, researcher, or explorer.

The `git-forge-delegator` complements the planner on mature projects. It turns
approved intent into forge issues with mechanical acceptance criteria. It
dispatches work by `agent:<slug>` label or assignment. It reviews the pull
requests that agents return. The forge is the delegation ledger.
