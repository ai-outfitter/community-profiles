---
name: persona-authoring
description: "Create or revise one portable, Markdown-first persona document per person or role. Use when recording who a project serves, defining a user or stakeholder, supplying durable project-steering context to agentic tools, or preparing a persona for an Outfitter review. Persona-specific information stays in the Markdown body; this skill authors context and does not run reviews."
---

# Persona authoring

Create one portable Markdown file for each persona. Store a persona that only
makes sense inside one project in that project's `docs/personas/`, and one
whose reader exists independently of any single repository in
`~/.agents/personas/`. Ask which tier applies when the answer is not obvious
from the request. Write it as project-steering context about **who** an agent
is helping. A tool
that accepts Markdown project context must be able to use the completed file
without Outfitter, a launcher, or schema-aware rendering.

Authoring may combine organization research, role archetypes, interviews, or
other approved inputs. Those are inputs, not runtime dependencies. What gets
committed is Markdown a person can read — one file by default.

## Author the canonical file

Start from [assets/template.persona.md](assets/template.persona.md). The
format is specified in Outfitter's
[Personas](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/personas.md)
doc.

1. Choose a stable lowercase, hyphen-separated filename for the persona.
   Prefer a generic role archetype (`platform-lead.md`,
   `founder-operator.md`) over a named individual; add a named persona only
   when a specific person's voice is the point.
2. Start directly with an H1 naming the role archetype (`# Platform Lead`) —
   or `# Name — Role` for the named-individual case. Do not introduce
   required frontmatter, a persona-specific schema, or a classifier. Put the
   role, organization, goals, concerns, constraints, decision signals, what
   the person notices when evaluating work, and voice in ordinary Markdown.
3. Use each section comment as a prompt for information the user supplied or
   explicitly approved, then remove every instructional comment. Do not invent
   demographics, income, biography, user research, or organizational policy.
4. Follow the H1 with a short first-person paragraph that naturally
   introduces the persona. Incorporate enough context to use the file without
   opening another document. When an identity is deliberately split — an
   organization shared across several roles — write each file to be complete
   about its own subject and silent about the others: a role document then
   names no sector or employer, and an organization document names no job.
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

One persona is one committed Markdown file with no frontmatter and no schema,
and it reads as ordinary prose on its own. Author a single file unless you have
a reason not to. Do not generate one Outfitter agent per persona, and do not
introduce a manifest, index, or settings key listing persona documents.

When part of an identity varies independently and would otherwise be copied into
every persona that shares it — one organization against several roles — that
part may be its own file, appended ahead of the role at launch. Each file must
still read on its own: it names no other file and leaves no placeholder for one.
Prefer a single file until the duplication actually hurts.

Using the document to steer ordinary project work and adopting its voice for a
review are separate use cases. When a review is requested, hand the same file
to the shared `persona-reviewer` agent through the launcher shipped with the
`persona-review` skill.
