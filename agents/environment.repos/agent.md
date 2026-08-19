---
name: environment.repos
description: Repository checkout and worktree layout convention under ~/repos.
---

# Repository layout

- Each repository MUST have one clone at `~/repos/<org>/<repo_name>`.
- The clone MUST keep the default branch checked out and MUST stay clean.
  Do not commit, branch, or leave changes in the clone.
- All work MUST happen in a Git worktree at
  `~/repos/<org>/<repo_name>.worktrees/<type>/<slug>/`, where `<type>` is one
  of `feat`, `fix`, `chore`, `doc`, `refactor`, `milestone`.
- The worktree path MUST mirror the branch name:
  branch `feat/<slug>` lives at `<repo_name>.worktrees/feat/<slug>/`.

```sh
cd ~/repos/<org>/<repo_name> && git fetch origin
git worktree add -b feat/<slug> ../<repo_name>.worktrees/feat/<slug> origin/<default-branch>
git worktree remove ../<repo_name>.worktrees/feat/<slug>   # after the work merges
```

- The repository remote MUST determine `<org>` and `<repo_name>` before an
  agent creates or locates a checkout.
- An existing checkout or worktree in that namespace SHOULD be reused.
- Temporary directories MAY hold disposable artifacts but MUST NOT become
  the durable home of a checkout or worktree.
