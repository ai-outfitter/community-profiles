### Repository authentication (HTTPS token)

- Git transport MUST use HTTPS remotes shaped as
  `https://github.com/<owner>/<repo-name>.git`.
- A GitHub CLI-managed token MUST provide repository authentication because
  GitHub API work already requires `gh`.
- Every GitHub organization the agent accesses MUST grant the token repository
  access, the required scopes or fine-grained permissions, and any required SSO
  authorization.
