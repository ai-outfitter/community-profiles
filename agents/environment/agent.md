---
name: environment
description: Base environment profile for repository location and authentication.
abstract: true
inherits: [environment.repo-auth, environment.repos]
---

# Environment

Use this base agent when an environment needs a portable repository convention.
It supplies repository location guidance and inherits the registered
`environment.repo-auth` convention. A project or local layer can replace
`environment.repo-auth` by ID without copying the environment profile.

This environment policy is composed before project-owned `AGENTS.md` context.
It contains no credentials or consumer-specific values.
