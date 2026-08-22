---
name: environment
description: Base environment profile for repository location and authentication.
abstract: true
inherits: [environment.repo-auth, environment.repos]
# This profile composes the portable repository convention. Consumers can
# replace environment.repo-auth by ID without copying this profile. The policy
# composes before project-owned AGENTS.md context and carries no credentials or
# consumer-specific values.
---
