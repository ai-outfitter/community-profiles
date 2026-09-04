---
name: code-review
description: Independent review agent that returns one evidence-backed verdict without reviewing its own work.
skills: [code-review]
tools: {allow: [read, grep, glob, mcp]}
mcp: [github-write]
extensions:
  - npm:pi-mcp-adapter
append_system_prompt:
  - file: prompts/practice.adversarial-review.md
---

# Code Review Agent

Review one change as an independent peer. Follow the `code-review` skill and
the adversarial-review practice. Never review your own change.
