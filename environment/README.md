# Environment base layers

These source layers are reusable starters for an agent's machine environment.
Each is one discrete `system-prompt.md` that establishes the shared
repository-location convention and one explicit repository authentication
strategy. HTTPS with a GitHub CLI-managed token is the default; SSH is an
opt-in alternative.

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
    path: environment/http-token
```

The environment source supplies the complete `system-prompt.md`.

## Use SSH instead

Replace the environment source:

```yaml
  - github: ai-outfitter/community-profiles
    ref: <same-tag-or-commit>
    path: environment/ssh
```

Do not mount both authentication layers.

## Copy and modify

Users who need a custom baseline can copy
[`http-token/system-prompt.md`](http-token/system-prompt.md) or
[`ssh/system-prompt.md`](ssh/system-prompt.md) into their own `.agents` payload,
then edit the copy.

`system-prompt.md` is selected whole-file by layer precedence. A user or project
with a higher-precedence `system-prompt.md` should copy the desired environment
starter into that layer and modify it there.
