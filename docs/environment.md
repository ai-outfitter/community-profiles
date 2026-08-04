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
