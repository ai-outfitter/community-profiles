# Persona documents and reviews

Each persona is one ordinary Markdown file, useful inside or outside
Outfitter. Authoring can compose many inputs, but the canonical artifact
committed to the repository is self-contained. Persona-specific information
lives in readable Markdown rather than configuration fields.

```text
normal project documentation
  personas/priya-nair.md
        |
        +-- added as context --> tools that accept Markdown context
        |
        `-- appended at launch -----------> shared persona-reviewer
                                               |
                                               `--> sourced report
```

## Author portable persona documents

`persona-authoring` is a catalog-level skill that any normal agent can select.
It creates one `kind: persona` Markdown file from user-supplied information.
It does not require an `.agents` directory or create Outfitter agents.

Store the documents wherever they remain useful to the user:

```text
docs/personas/
  priya-nair.md
  software-engineer.md
```

The frontmatter contains only the generic `kind: persona` classifier. The H1,
opening introduction, responsibilities, goals, concerns, constraints,
decision-making signals, and voice all live in the Markdown body. The template
uses Markdown comments as authoring prompts; a completed file removes those
comments and reads like normal project documentation.

To test portability, add the completed document unchanged to an agentic tool
that accepts Markdown project context. For normal project work, tell the tool
to treat it as stakeholder context rather than as its identity or as runtime
instructions. The same file can steer product planning, research, writing,
design review, or a review written from that person's point of view. Outfitter
is one optional consumer.

## Keep the portable document separate from runtime packaging

Plain Markdown persona documents are canonical because they keep durable
context independent of any runtime and can live with the project's other
documentation. This follows the `.agents`-first philosophy: keep agent-facing
knowledge harness-neutral, then add runtime adapters. Knowing who the user or
stakeholder is can improve ordinary project decisions without modeling that
person as an executable agent.

An Outfitter-native representation is a separate integration use case. A
future design could make a persona an `.agents/agents/<slug>/agent.md`
resource, or allow a proposed `.agents/outfitter/settings.yml` layer to point
at ordinary persona documents. Neither form is required or implemented by
this convention. Document and validate that runtime-specific design
separately rather than making the portable persona depend on it.

## Use one shared Outfitter profile

The catalog ships `persona-reviewer`, a normal agent whose stable loadout
selects `persona-review`. It has no customer identity of its own. One
self-contained persona document is appended at launch and exists only for that
session.

The `persona-review` skill ships a reusable launcher:

```bash
bash skills/persona-review/scripts/persona-review.sh \
  --persona docs/personas/priya-nair.md \
  -- --print "Review the supplied artifact and write the report. @README.md"
```

Projects can wrap the same pattern in a local `bin/persona-review` to provide
named roles, review types, session export, or report destinations. Both paths
ultimately run:

```bash
outfitter run persona-reviewer -- \
  --append-system-prompt <persona> \
  <harness arguments>
```

## Responsibility boundary

- `persona-authoring` creates one portable, committed file per persona.
- `persona-reviewer` is the single shared Outfitter agent profile.
- `persona-review` provides review and report behavior plus the generic launch
  script.
- Project wrappers choose documents and handle project-specific concerns such
  as session capture or publication.

Adding a persona means adding exactly one document, not maintaining another
Outfitter agent or a runtime chain of fragments. Reports stay inside the
adopted identity and do not explain this framework; publishing systems own
provenance metadata.
