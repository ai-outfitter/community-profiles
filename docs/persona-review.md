# Persona documents and reviews

Each persona is one ordinary Markdown file, useful inside or outside
Outfitter. Authoring can compose many inputs, but the canonical artifact
committed to the repository is self-contained. Outfitter provides one shared
profile and appends the selected persona file only for the run:

```text
normal user documentation
  priya-nair.md
          |
          | bin/persona-review or the shipped skill script
          v
shared persona-reviewer agent
  + persona-review skill
          |
          v
sourced first-person report
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

The same files can support product planning, research, writing, design review,
or another tool. Outfitter is only one consumer.

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
