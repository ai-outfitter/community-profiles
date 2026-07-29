# System-prompt convention groups

This flat directory collects reusable system-prompt convention groups. File
names follow `<group>.<topic>.<variant>.md`, so related conventions sort
together and remain individually composable.

The environment repository prompts establish the shared repository-location
convention and one explicit authentication strategy. HTTPS with a GitHub
CLI-managed token is the default; SSH is an alternative.

[`AGENTS.md`](AGENTS.md) defines the authoring contract for every prompt in this
directory.

## Use the default HTTPS/token environment

Copy the HTTP-token prompt to the system-prompt location in the layer that
should own the convention:

```sh
cp system-prompts/environment.repo.http-token.md ~/.agents/system-prompt.md
```

An agent profile or launch command MAY append the same file when the selected
harness supports prompt-file composition.

## Use SSH instead

```sh
cp system-prompts/environment.repo.ssh.md ~/.agents/system-prompt.md
```

## Copy and modify

Users who need a custom baseline can copy
[`environment.repo.http-token.md`](environment.repo.http-token.md) or
[`environment.repo.ssh.md`](environment.repo.ssh.md) into their own `.agents`
payload, then edit the copy.

`system-prompt.md` is selected whole-file by layer precedence. A user or project
with a higher-precedence `system-prompt.md` should copy the desired environment
starter into that layer and modify it there.
