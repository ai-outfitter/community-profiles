# System-prompt convention groups

This flat directory collects reusable system-prompt convention groups. File
names follow `<group>.<topic>[.<variant>].md`, so related conventions sort
together and remain individually composable.

`environment.repos.md` establishes the shared repository-location convention.
The `environment.repo.*` prompts establish explicit authentication strategies.
HTTPS with a GitHub CLI-managed token is the default; SSH is an alternative.

[`AGENTS.md`](AGENTS.md) defines the authoring contract for every prompt in this
directory.

## Use the default HTTPS/token environment

Compose the repository and HTTP-token prompts in this order at the
system-prompt layer:

- [`environment.repos.md`](environment.repos.md)
- [`environment.repo.http-token.md`](environment.repo.http-token.md)

An agent profile or launch command MAY append the same file when the selected
harness supports prompt-file composition.

## Use SSH instead

Compose [`environment.repos.md`](environment.repos.md), then
[`environment.repo.ssh.md`](environment.repo.ssh.md).

## Copy and modify

Users who need a custom baseline can copy [`environment.repos.md`](environment.repos.md)
and one authentication prompt into their own `.agents` payload, then edit the
copies.

`system-prompt.md` is selected whole-file by layer precedence. A user or project
with a higher-precedence `system-prompt.md` should copy the desired environment
starter into that layer and modify it there.
