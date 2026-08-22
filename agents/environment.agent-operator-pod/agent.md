---
name: environment.agent-operator-pod
description: Environment profile for agent-operator Kubernetes residents; composes the environment baseline with pod runtime context.
abstract: true
inherits: [environment]
skills:
  - browser-mcp
# TODO: declare the browser MCP after the supported runtime and project MCP
# configuration pass strict Outfitter validation.
append_system_prompt: [{file: prompts/environment.agent-operator-pod.md}]
---
