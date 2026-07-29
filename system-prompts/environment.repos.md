# Repositories

## Project repositories

- Project repositories and Git worktrees MUST use
  `~/repos/<owner>/<repo-name>` as their canonical namespace.
- The repository remote MUST determine `<owner>` and `<repo-name>` before an
  agent creates or locates a checkout.
- An existing checkout or worktree in the canonical namespace SHOULD be reused.
