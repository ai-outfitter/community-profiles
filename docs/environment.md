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

## Kubernetes residents

The `agent-operator-pod` agent extends the baseline for resident agents that
agent-operator deploys into Kubernetes pods. It inherits `environment`, so a
resident inherits one slug and receives repository conventions,
authentication, and pod runtime context (namespace scope, persistent
workspace, durable task re-offers, resource quota bounds, the Chrome sidecar,
and operator-provisioned credentials):

```yaml
---
name: luce
inherits: [agent-operator-pod]
---
```

Until the agent-operator Organization supports more than one catalog source,
an org catalog that wants this chain vendors `agents/agent-operator-pod/`,
`agents/environment/`, and `agents/repo-auth/` verbatim; the same-slug
override rule still applies (an org replaces `repo-auth` to switch forge or
transport). Delete the vendored copies once residents can layer this catalog
directly.

## Ephemeral CI runners

The `actions-runner` agent is the environment for agents that
ai-outfitter/actions launches on a GitHub or Forgejo runner. It inherits
`repo-auth` but **not** `environment`: the repository is already checked out
at the working directory, so the workstation `~/repos` layout does not
apply. It states the runner realities — ephemeral disk, hard timeout,
invisible stdout, forge-posted results, label-based routing.
`actions-agent` inherits it.

## Confined read-only research

The `container-readonly` agent is the environment for subagents doing
read-only research or planning in a locked-down container. It carries
`tools.deny: [bash, write, edit]` — and because tool denies union across an
inheritance chain, a child profile cannot restore what it denies. The
runtime this profile targets (a container with a read-only workspace mount,
writable `/tmp` only, and no egress beyond what research requires) is
documented intent; the image variant ships separately.

The `planner` agent is the first profile built for that use: a read-only
explorer with `thinking: high` whose only write authority exists to emit
its plan artifact. It composes with delegation harnesses that name an
output file, and works as a directly-run agent too. `git-forge-delegator`
is its complement on mature projects: instead of planning local work, it
turns intent into forge issues with mechanical acceptance criteria,
dispatches them by `agent:<slug>` label or assignment, and reviews the
returning pull requests — the forge is the delegation ledger.
