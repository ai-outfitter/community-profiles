# Environment baseline

The `environment` agent is a base profile for agents that need a stable
repository convention. It inherits `environment.repo-auth` and
`environment.repos`. A consumer can inherit `environment` to receive both
repository location and authentication guidance.

```yaml
---
name: software-development
description: Agent for implementation work.
inherits: [environment]
---
```

The effective resource set resolves each agent slug across layers. A higher
precedence layer can replace `agents/environment.repo-auth/agent.md` with the
same `name: environment.repo-auth` and select another approved Git transport.
This override avoids separate authentication variants in this catalog.

The catalog's default `environment.repo-auth` resource uses HTTPS and a GitHub
CLI-managed token. An environment that uses SSH can replace that resource with
this compact shape and keep the same slug:

```yaml
---
name: environment.repo-auth
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

Environment profiles are loadout shells. Their frontmatter declares
capability, inheritance, and `append_system_prompt`; their reusable prose lives
in same-named `prompts/environment.*.md` fragments. Appended fragments compose
before profile bodies, in inherited-then-child order. A same-slug override can
replace a shell's capability or append list without copying unrelated profiles;
when it keeps the canonical append path, it continues to use that fragment.

## Profile taxonomy

A profile is either a **runnable agent** or an **abstract composable**.

An abstract profile declares `abstract: true`. It exists to be inherited and
MUST NOT be run directly or named as `default_agent`. The abstract environment
profiles are `environment`, `environment.repos`, `environment.repo-auth`,
`environment.agent-operator-pod`, `environment.actions-runner`, and
`environment.container-readonly`. The `git-forge-delegator` profile is an
abstract practice, and `agent-operator-resident` is the abstract resident
contract. All other profiles are runnable.

Two kinds of abstract profile compose differently:

- An **environment** describes where an agent runs and the tool policy that
  runtime enforces. An agent takes one runtime environment.
- A **practice** describes how an agent works, independent of where. An agent
  MAY take several.

`abstract: true` is metadata that older Outfitter releases ignore because the
agent schema accepts additional properties. A future Outfitter release can use
the field to reject an abstract run target or `default_agent`.

Environment-specific profiles use the `environment.*` namespace. The base
composition profile keeps the short `environment` slug.

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
explorer inherits `environment.container-readonly`. The researcher does not
select a runtime environment. A caller MAY compose a suitable environment with
the researcher at deployment time.

## Kubernetes residents

The `environment.agent-operator-pod` profile extends the baseline for
Kubernetes residents. It inherits `environment`, which supplies the repository
and authentication rules. Its shell appends the fragment that supplies the pod
runtime context:
namespace scope, persistent workspace, durable task re-offers, resource limits,
the Chrome sidecar, and operator-provisioned credentials:

```yaml
---
name: resident
inherits: [environment.agent-operator-pod]
---
```

An organization catalog MAY vendor `agents/environment.agent-operator-pod/`,
`agents/environment/`, and `agents/environment.repo-auth/` when its runtime
cannot layer this catalog directly. The same-slug override rule still applies.
An organization can replace `environment.repo-auth` to select another forge or
transport. Remove the vendored copies when the runtime supports direct catalog
layers.

## Ephemeral CI runners

The `environment.actions-runner` profile is for agents that
ai-outfitter/actions launches on a GitHub or Forgejo runner. It does not inherit
`environment`. The repository already exists in the working directory, so the
workstation `~/repos` layout does not apply. The profile states the runner
limits and result channels. The `actions-agent` profile inherits it. A
GitHub-specific child MAY inherit `environment.repo-auth`.

## Confined read-only exploration

The `environment.container-readonly` profile is for work in a locked-down
container. It denies `bash`, `write`, and `edit`. Inherited deny lists combine,
so a child profile cannot restore these tools. The intended runtime has a
read-only workspace, a writable `/tmp`, and only the required network access.

The `explorer` profile inherits `environment.container-readonly`. The
`researcher` profile does not inherit it and does not define a read-only tool
allow list. A researcher can write durable research notes, persona documents,
and review reports. Use the explorer when a task MUST only inspect data.

The `git-forge-delegator` complements the planner on mature projects. It turns
approved intent into forge issues with mechanical acceptance criteria. It
dispatches work by `agent:<slug>` label or assignment. It reviews the pull
requests that agents return. The forge is the delegation ledger.
