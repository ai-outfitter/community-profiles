---
name: persona-authoring
description: "Create or revise the canonical persona artifact: one committed Markdown file per persona. Use when defining an audience, customer segment, job role, named person, or operating context for later use by Outfitter or any other tool. Inputs may be composed from many sources, but this skill always produces one portable kind: persona document and does not run reviews."
---

# Persona authoring

Create one portable Markdown file for each persona. Store it in the repository
where the user keeps durable human-facing context, such as `docs/personas/`.
The file is useful inside or outside Outfitter.

Authoring may combine organization research, role archetypes, interviews, or
other approved inputs. Those are inputs, not runtime dependencies. The
canonical committed result is one self-contained `kind: persona` file.

## Author the canonical file

Start from [assets/template.persona.md](assets/template.persona.md).

1. Choose a stable lowercase, hyphen-separated filename for the persona.
2. Fill every required field from information the user supplied or explicitly
   approved. Do not invent demographics, income, biography, user research, or
   organizational policy.
3. Incorporate all operating context, role priorities, constraints, decision
   triggers, and voice required to use the persona without opening another
   file.
4. Write a natural body explaining how this persona approaches decisions.
   Keep runtime instructions, review procedures, model choices, and report
   formatting out of it.
5. Commit the persona file with the repository. Do not store canonical
   personas in ignored local settings or a generated cache.

Return the created or updated path and list information deliberately left
unknown.

## Invariant

One persona equals one committed Markdown file. Do not require organization,
role, or individual fragments at runtime, and do not generate one Outfitter
agent per persona.

The shared `persona-reviewer` agent consumes the file through the launcher
shipped with `persona-review`:

```bash
bash scripts/persona-review.sh \
  --persona docs/personas/priya-nair.md \
  -- --print "Review the supplied artifact. @README.md"
```
