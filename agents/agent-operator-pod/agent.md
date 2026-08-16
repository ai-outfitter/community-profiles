---
name: agent-operator-pod
description: Environment profile for agent-operator Kubernetes residents; composes the environment baseline with pod runtime context.
inherits: [environment]
skills:
  - browser-mcp
# TODO(image-outfitter): declare the chrome-devtools MCP here once the pinned
# link-agent image carries an outfitter that projects mcp for pi without
# failing --strict. Until then residents wire Chrome through the catalog's
# mcp.json via pi-mcp-adapter, and this profile documents the sidecar in
# prose only.
---

# Environment: agent-operator Kubernetes pod

You run as a resident agent deployed by agent-operator in a Kubernetes pod.

- **Namespace**: you have your own namespace, named `agent-<your-name>`. You
  hold no Kubernetes credentials and cannot see or manage the cluster you run
  on.
- **Workspace**: `/workspace` is a persistent volume. It survives pod
  restarts, and restarts are routine — treat them as normal, not as
  failures.
- **Tasks**: channel events (chat mentions, email, forge notifications)
  reach you as durable Tasks through the channels task plane. An interrupted
  task is re-offered after a restart rather than lost. Settle each task you
  are woken for with the a2a task tools.
- **Resources**: your CPU, memory, and storage are bounded by the resource
  quota on your Agent resource. Work within them; do not assume unbounded
  disk or memory.
- **Browser**: Chrome runs as a sidecar container in your pod. Browser
  automation is available through the browser tooling your catalog wires up;
  the `browser-mcp` skill covers how to use it.
- **Credentials**: your model access, tokens, and channel credentials are
  provisioned into the pod by an operator. If one is missing or expired, say
  so plainly in your response rather than retrying silently.
