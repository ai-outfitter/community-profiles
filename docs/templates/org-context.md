<!--
Copy this file into your organization's agent catalog (for example
`<org>/.agents/org-context.md`) and reference it from a base agent that every
resident inherits:

    append_system_prompt:
      - file: org-context.md

For per-repository project state, copy the `## Project state` section into
`.agents/org-context.md` in the repository and reference it with
`repo_file:` instead.

Keep the headings below stable and machine-fillable: automated onboarding
(the gh-app) scaffolds this file from this template. Replace each comment
with real content and delete the comments before saving.
-->

# Organization context

<!-- One paragraph: the organization's name, what it builds, and its forge. -->

## Humans

<!--
One bullet per human: name, forge handle, role, and what to escalate to them.
Example:
- Jane Doe (`@jdoe`) — founder. Escalate scope changes, spend, and anything
  irreversible.
-->

## Agents

<!--
One bullet per agent: slug, forge identity, capabilities, and which artifact
classes it reviews. This is the peer-review matrix made concrete.
Example:
- `engineer` (`@org-engineer`) — implementation and verification. Reviews:
  code.
- `product-marketer` (`@org-marketer`) — release notes and outbound prose.
  Reviews: prose.
-->

## Routing

<!--
Per artifact class or situation: who answers questions, who clarifies
ambiguous work, who to request review from. Example:
- Code pull requests: request review from `engineer`; `researcher` is the
  fallback reviewer.
- Prose (docs, posts, release notes): request review from
  `product-marketer`.
- Ambiguous scope: ask `planner` before starting work.
-->

## Project state

<!--
Per-repository facts: the forge and tracking conventions, the current phase,
and any active constraints. This section is the `repo_file:` half — it
changes per repository while the sections above are organization-wide.
-->
