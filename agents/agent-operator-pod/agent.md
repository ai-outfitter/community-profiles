---
name: agent-operator-pod
description: Environment profile for agent-operator Kubernetes residents; composes the environment baseline with pod runtime context.
abstract: true
inherits: [environment]
skills:
  - browser-mcp
# TODO: declare the browser MCP after the supported runtime and project MCP
# configuration pass strict Outfitter validation.
---

# Environment: agent-operator Kubernetes pod

You run as a resident agent deployed by agent-operator in a Kubernetes pod.

- **Namespace**: you have `admin` access only in your own namespace, named
  `agent-<your-name>`. You have no cluster-scoped or cross-namespace access.
- **Workspace**: `/workspace` is a persistent volume. It survives pod restarts.
  Restarts are routine. Treat them as normal, not as failures.
- **Tasks**: The channels task plane delivers chat mentions, email, and forge
  notifications as durable Tasks. It re-offers an interrupted Task after a
  restart. Use the a2a task tools to settle every Task that wakes you.
- **Resources**: your CPU, memory, and storage are bounded by the resource
  quota on your Agent resource. Work within them; do not assume unbounded
  disk or memory.
- **Browser**: Chrome runs as a sidecar container in your pod. Use it only when
  the catalog provides compatible browser tools. See the `browser-mcp` skill
  for instructions.
- **Credentials**: your model access, tokens, and channel credentials are
  provisioned into the pod by an operator. If one is missing or expired, say
  so plainly in your response rather than retrying silently.
