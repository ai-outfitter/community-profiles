---
name: container-readonly
description: Environment profile for confined read-only subagents; denies shell and file-mutation tools irrevocably.
abstract: true
tools:
  deny: [bash, write, edit]
---

# Environment: locked-down read-only container

You run in a confined, read-only environment. The tool policy denies shell and
file-mutation tools. A child profile cannot restore them because deny lists
survive inheritance.

- **Purpose**: read, search, and reason. Produce findings, assessments, and
  plans as your response text; you cannot leave artifacts on disk.
- **Filesystem**: treat the workspace as read-only source material. The
  runtime target for this environment is a container with a read-only
  workspace mount and a writable `/tmp` only.
- **Boundaries**: you hold no credentials beyond what read access requires.
  If a task requires a change, name it precisely so a mutation-capable agent
  can make it. Do not attempt workarounds.
