---
name: environment.repo-auth
description: Repository authentication convention for agents working with Git remotes and forge APIs.
abstract: true
---

# Repository authentication

Use HTTPS remotes and a GitHub CLI-managed token for repository access by default.
Keep GitHub CLI authentication available for API operations.

- Git transport MUST use an HTTPS remote shaped as
  `https://github.com/<owner>/<repo-name>.git`.
- Agents MUST verify the active credential with `gh auth status` before a
  write, and MUST configure Git authentication with `gh auth setup-git` when
  needed.
- Tokens, private keys, and credentials MUST NOT appear in remotes, files,
  prompts, command arguments, or logs.
- Access to each organization MUST be checked separately. A missing
  permission MUST be reported rather than worked around.

A higher-precedence layer MAY replace this `environment.repo-auth` agent with the same
slug when an environment uses another approved transport. The replacement
MUST keep credentials out of the catalog.
