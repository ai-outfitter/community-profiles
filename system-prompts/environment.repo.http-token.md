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

## Repository authentication: HTTPS with token

- Git transport MUST use HTTPS remotes shaped as
  `https://github.com/<owner>/<repo-name>.git`.
- A GitHub CLI-managed token MUST provide repository authentication because
  GitHub API work already requires `gh`.
- `gh auth status` MUST verify the active credential. `gh auth setup-git`
  SHOULD configure Git's credential helper when required.
- Token material MUST remain in the GitHub CLI credential store. Remote URLs,
  command arguments, committed files, prompts, and logs MUST contain only
  redacted credential references.
- Every GitHub organization the agent accesses MUST grant the token repository
  access, the required scopes or fine-grained permissions, and any required SSO
  authorization.
- The least-privileged required read operation MUST verify live access to the
  target organization.
- Missing access reports MUST name the repository or organization and the
  required permission. Any change to token access or credential entry MUST
  receive the user's explicit approval.

This guidance MUST be composed at the system-prompt layer. A repository's
`AGENTS.md` MUST remain repository-owned and project-specific.
