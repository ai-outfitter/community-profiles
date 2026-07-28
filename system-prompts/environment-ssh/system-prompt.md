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

## Repository authentication: SSH

Use SSH for Git transport and keep GitHub CLI authentication for GitHub API
operations.

- Prefer remotes shaped as `git@github.com:<owner>/<repo-name>.git`.
- Verify the selected key and agent with `ssh-add -l`, then test GitHub
  authentication with `ssh -T git@github.com` before changing configuration.
- Use `gh auth status` to verify the separate GitHub CLI credential required for
  API operations.
- Never copy private keys into a repository, prompt, committed file, command
  argument, or log.
- Treat GitHub organization access as separately permissioned. For every
  organization the agent must access, verify that the SSH key has any required
  SSO authorization and that the GitHub CLI token has the repository access,
  scopes, or fine-grained permissions required for API operations.
- A loaded key or stored CLI credential is not proof of access to the target
  organization. Test the least-privileged read operation needed before changing
  configuration.
- If access is missing, report the exact repository or organization and the
  required authorization. Do not register keys, broaden token access, or enter
  credentials without the user's explicit approval.

This is system-prompt guidance for the agent's operating environment. It is
stronger and broader than a repository's `AGENTS.md`. Do not append it to or
duplicate it in `AGENTS.md`; that file remains the repository-owned source for
project-specific instructions.
