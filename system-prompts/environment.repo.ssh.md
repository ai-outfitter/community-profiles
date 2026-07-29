### SSH Repository authentication

- Git transport MUST use SSH remotes shaped as
  `git@github.com:<owner>/<repo-name>.git`.
- GitHub CLI authentication MUST provide the credential required for GitHub API
  operations.
- Every GitHub organization the agent accesses MUST grant the SSH key any
  required SSO authorization and grant the GitHub CLI token the repository
  access required for API operations.
