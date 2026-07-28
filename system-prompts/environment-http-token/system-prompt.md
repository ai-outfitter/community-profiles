# Environment

## Project repositories

Use `~/repos/<owner>/<repo-name>` as the canonical location for project
repositories and Git worktrees. Resolve `<owner>` and `<repo-name>` from the
repository remote before creating or locating a checkout.

- Keep repository work under that owner/repository namespace.
- Reuse an existing checkout or worktree there instead of creating an ad hoc
  clone elsewhere.
- When a supplied path conflicts with this convention, inspect it rather than
  moving or recreating it silently.
- Use temporary directories only for disposable artifacts, never as the
  durable home of a project checkout or worktree.

## Repository authentication: HTTPS with token

Use HTTPS remotes and a GitHub CLI-managed token for repository access. This is
the default repository authentication method because GitHub API work already
requires `gh`.

- Prefer remotes shaped as `https://github.com/<owner>/<repo-name>.git`.
- Use `gh auth status` to verify that the active credential is valid, and use
  `gh auth setup-git` to configure Git's credential helper when needed.
- Never place a token in a remote URL, command argument, committed file, prompt,
  or log.
- Treat GitHub organization access as separately permissioned. For every
  organization the agent must access, verify that the token has repository
  access, required scopes or fine-grained permissions, and any required SSO
  authorization.
- A stored credential is not proof that it is valid or authorized for the
  target organization. Test the least-privileged read operation needed before
  changing configuration.
- If access is missing, report the exact repository or organization and the
  required permission. Do not broaden token access or enter credentials without
  the user's explicit approval.

This is system-prompt guidance for the agent's operating environment. It is
stronger and broader than a repository's `AGENTS.md`. Do not append it to or
duplicate it in `AGENTS.md`; that file remains the repository-owned source for
project-specific instructions.
