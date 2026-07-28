# System-prompt convention groups

This directory collects reusable groups of system-prompt conventions. Each
selectable group has a domain-prefixed directory name and contains one complete
`system-prompt.md` payload.

The environment groups establish the shared repository-location convention and
one explicit repository authentication strategy. HTTPS with a GitHub
CLI-managed token is the default; SSH is an opt-in alternative.

This guidance belongs in the composed system prompt. It is intentionally not an
addition to a project's `AGENTS.md`: the environment policy applies before and
across projects, while `AGENTS.md` remains repository-owned, project-specific
context.

## Use the default HTTPS/token environment

Mount the HTTP-token environment after the catalog that supplies the agents and
skills:

```yaml
sources:
  - github: ai-outfitter/community-profiles
    ref: <tag-or-commit>
  - github: ai-outfitter/community-profiles
    ref: <tag-or-commit>
    path: system-prompts/environment-http-token
```

The environment source supplies the complete `system-prompt.md`.

## Use SSH instead

Replace the environment source:

```yaml
  - github: ai-outfitter/community-profiles
    ref: <same-tag-or-commit>
    path: system-prompts/environment-ssh
```

Do not mount both authentication layers.

## Copy and modify

Users who need a custom baseline can copy
[`environment-http-token/system-prompt.md`](environment-http-token/system-prompt.md)
or
[`environment-ssh/system-prompt.md`](environment-ssh/system-prompt.md) into
their own `.agents` payload, then edit the copy.

`system-prompt.md` is selected whole-file by layer precedence. A user or project
with a higher-precedence `system-prompt.md` should copy the desired environment
starter into that layer and modify it there.
