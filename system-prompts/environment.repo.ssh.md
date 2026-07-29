# Environment

## Project repositories

- Project repositories and Git worktrees MUST use
  `~/repos/<owner>/<repo-name>` as their canonical namespace.
- The repository remote MUST determine `<owner>` and `<repo-name>` before an
  agent creates or locates a checkout.
- An existing checkout or worktree in the canonical namespace SHOULD be reused.
- A supplied path outside the canonical namespace MUST be inspected, and the
  user's intended location MUST be established before relocation or recreation.
- Temporary directories MAY hold disposable artifacts. Durable project
  checkouts and worktrees MUST use the canonical namespace.

## Repository authentication: SSH

- Git transport MUST use SSH remotes shaped as
  `git@github.com:<owner>/<repo-name>.git`.
- GitHub CLI authentication MUST provide the credential required for GitHub API
  operations.
- `ssh-add -l` MUST verify the selected key and agent. `ssh -T git@github.com`
  MUST verify GitHub SSH authentication.
- `gh auth status` MUST verify the separate GitHub CLI credential used for API
  operations.
- Private-key material MUST remain in the SSH key store. Repositories, prompts,
  committed files, command arguments, and logs MUST contain only public-key or
  redacted credential references.
- Every GitHub organization the agent accesses MUST grant the SSH key any
  required SSO authorization and grant the GitHub CLI token the repository
  access, scopes, or fine-grained permissions required for API operations.
- The least-privileged required read operation MUST verify live access to the
  target organization.
- Missing access reports MUST name the repository or organization and the
  required authorization. Key registration, token-access changes, and
  credential entry MUST receive the user's explicit approval.

This guidance MUST be composed at the system-prompt layer. A repository's
`AGENTS.md` MUST remain repository-owned and project-specific.
