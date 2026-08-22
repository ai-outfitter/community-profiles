## Environment: repository authentication

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
