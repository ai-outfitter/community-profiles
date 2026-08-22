Keep one clean default-branch clone at `~/repos/<org>/<repo>` and make changes
only in a sibling worktree at
`~/repos/<org>/<repo>.worktrees/<type>/<slug>/`. The worktree path mirrors its
semantic branch name. Reuse an existing matching worktree. Use the repository
remote to resolve the organization and repository name. Use temporary
directories only for disposable artifacts.
