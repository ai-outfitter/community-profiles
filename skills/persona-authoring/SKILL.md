---
name: persona-authoring
description: "Create or revise one portable, Markdown-first persona document per person or role. Use when recording who a project serves, defining a user or stakeholder, supplying durable project-steering context to agentic tools, or preparing a persona for an Outfitter review. Persona-specific information stays in the Markdown body; this skill authors context and does not run reviews."
---

# Persona authoring

Create one portable Markdown file for each persona. Store it in the repository
where the user keeps durable human-facing context, such as `docs/personas/`.
Write it as project-steering context about **who** an agent is helping. A tool
that accepts Markdown project context must be able to use the completed file
without Outfitter, a launcher, or schema-aware rendering.

Authoring may combine organization research, role archetypes, interviews, or
other approved inputs. Those are inputs, not runtime dependencies. The
canonical committed result is one self-contained `kind: persona` file.

## Author the canonical file

Start from [assets/template.persona.md](assets/template.persona.md).

1. Choose a stable lowercase, hyphen-separated filename for the persona.
2. Leave only the generic `kind: persona` classifier in frontmatter. Put the
   name, role, organization, goals, concerns, constraints, decision signals,
   what the person notices when evaluating work, and voice in ordinary
   Markdown.
3. Use each section comment as a prompt for information the user supplied or
   explicitly approved, then remove every instructional comment. Do not invent
   demographics, income, biography, user research, or organizational policy.
4. Start with an H1 and a short first-person paragraph that naturally
   introduces the person. Incorporate enough context to use the file without
   opening organization, role, or individual fragments.
5. Prefer connected prose and meaningful headings over a serialized field
   list. Keep runtime instructions, review procedures, model choices, and
   report formatting out of the persona.
6. Link supporting research when available. Distinguish sourced observations,
   approved assumptions, and material unknowns in the Markdown body when that
   distinction affects how an agent should use the persona.
7. Read the finished file as if it had been added to a different tool's
   Markdown project context. Revise anything that assumes Outfitter or the
   authoring template, and verify that no comments or placeholders remain.
8. Commit the persona file with the repository. Do not store canonical
   personas in ignored local settings or a generated cache.

Return the created or updated path and list information deliberately left
unknown.

## Invariant

One persona equals one committed Markdown file. Do not require organization,
role, or individual fragments at runtime, and do not generate one Outfitter
agent per persona.

Using the document to steer ordinary project work and adopting its voice for a
review are separate use cases. When a review is requested, the shared
`persona-reviewer` agent can consume the same file through the launcher shipped
with `persona-review`:

```bash
bash scripts/persona-review.sh \
  --persona docs/personas/priya-nair.md \
  -- --print "Review the supplied artifact. @README.md"
```
