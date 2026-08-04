---
name: environment
description: Base environment profile for repository location and authentication.
inherits: [repo-auth]
---

# Environment

Use this base agent when an environment needs a portable repository convention.
It supplies repository location guidance and inherits the registered `repo-auth`
convention. A project or local layer can replace `repo-auth` by ID without
copying the environment profile.

## Project repositories

- Project repositories and Git worktrees MUST use
  `~/repos/<owner>/<repo-name>` as their canonical namespace.
- The repository remote MUST determine `<owner>` and `<repo-name>` before an
  agent creates or locates a checkout.
- An existing checkout or worktree in that namespace SHOULD be reused.
- Temporary directories MAY hold disposable artifacts but MUST NOT become the
  durable home of a project checkout or worktree.

This environment policy is composed before project-owned `AGENTS.md` context.
It contains no credentials or consumer-specific values.
