# Persona documents and reviews

Each persona is one ordinary Markdown file, useful inside or outside
Outfitter. Authoring can compose many inputs, but the canonical artifact
committed to the repository is self-contained. Persona-specific information
lives in readable Markdown rather than configuration fields.

Outfitter's
[Personas](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/personas.md)
doc defines the file format, and its
[Persona reviews](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/usecases/persona-reviews.md)
use case walks the author → run → paste-anywhere story. This page covers the
catalog's setup and runtime boundary.

```text
normal project documentation
  personas/platform-lead.md
        |
        +-- added as context --> tools that accept Markdown context
        |
        `-- appended at launch -----------> shared persona-reviewer
                                               |
                                               `--> sourced report
```

## Author portable persona documents

`persona-authoring` is a catalog-level skill that any normal agent can select.
It creates one self-contained Markdown file from user-supplied information. It
does not require an `.agents` directory or create Outfitter agents.

Commit the documents beside the project's other durable context,
`docs/personas/` by convention:

```text
docs/personas/
  platform-lead.md
  founder-operator.md
```

The canonical document requires no frontmatter or persona-specific schema. Its
H1, opening introduction, responsibilities, goals, concerns, constraints,
decision-making signals, and voice all live in ordinary Markdown. The template
uses Markdown comments as authoring prompts; a completed file removes those
comments and reads like normal project documentation.

Paste or upload the file unchanged into a web agent (claude.ai project
knowledge, a ChatGPT project) or another agentic tool that accepts Markdown
project context. For normal project work, tell the tool to treat it as
stakeholder context, not as its own identity. The same file can steer product
planning, research, or design review. Outfitter is one optional consumer.

## Keep the portable document separate from runtime packaging

Plain Markdown persona documents are canonical because they keep durable
context independent of any runtime and can live with the project's other
documentation. This follows the `.agents`-first philosophy: keep agent-facing
knowledge harness-neutral, then add runtime adapters. Knowing who the user or
stakeholder is can improve ordinary project decisions without modeling that
person as an executable agent.

An Outfitter-native representation is a separate, deferred design; the
portable persona must never depend on it. See the Status section of the
[Personas](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/personas.md)
spec.

## Use one shared reviewer agent

The catalog ships `persona-reviewer`, a normal agent whose stable loadout
selects `persona-review`. It has no customer identity of its own. One
self-contained persona document is appended at launch and exists only for that
session.

The `persona-review` skill ships a reusable launcher:

```bash
bash skills/persona-review/scripts/persona-review.sh \
  --persona docs/personas/platform-lead.md \
  -- --print "Review the supplied artifact and write the report. @README.md"
```

Projects can wrap the same pattern in a local `bin/persona-review` to provide
named roles, review types, session export, or report destinations. Both paths
resolve the persona path and run:

```bash
outfitter run persona-reviewer -- \
  --append-system-prompt <persona> \
  <harness arguments>
```

## Responsibility boundary

- `persona-authoring` creates one portable, committed file per persona.
- `persona-reviewer` is the shared reviewer agent.
- `persona-review` provides review and report behavior plus the generic launch
  script.
- Project wrappers choose documents and handle project-specific concerns such
  as session capture or publication.

Reports stay inside the adopted identity and do not explain this framework;
publishing systems own provenance metadata.
