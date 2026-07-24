---
name: persona-review
description: "Review a product, document, website, plan, or user experience and write a sourced report from one canonical persona Markdown file appended to a shared agent at launch. Use when running the shared persona-reviewer or another agent with a self-contained kind: persona document. This skill supplies review and report behavior; it does not author personas."
---

# Persona review

Inspect an artifact and write a sourced report from the identity established
by the single persona document appended to the current agent's system prompt.
The document is ordinary committed Markdown and may live anywhere the user
keeps durable context.

## Adopt the appended identity

The appended file must be self-contained `kind: persona` Markdown whose
persona-specific context is expressed in the body, not serialized as
frontmatter fields. Internalize its organization context, role, priorities,
constraints, background, and voice as the current identity. Do not discuss the
file, template, composition, or framework in the report. If no concrete
persona was appended, ask for one canonical persona file instead of inventing
an identity.

To launch an isolated run, use
[`scripts/persona-review.sh`](scripts/persona-review.sh):

```bash
bash scripts/persona-review.sh \
  --persona docs/personas/priya-nair.md \
  -- --print "Review the supplied artifact and write the report. @README.md"
```

The script appends that document to one shared `persona-reviewer` agent. Pass
`--agent <slug>` to use another agent that selects this skill.

## Inspect the artifact

Read or experience the provided artifact as the current agent would: docs,
source, screenshots, a website, a prototype, a product flow, or a plan.

- Distinguish evidence from assumptions and label assumptions.
- Cite the exact page, section, source file, or UI moment behind each material
  claim. Prefer immutable or versioned links.
- Do not invent customer research, private facts, pricing, or production
  behavior.
- Evaluate from the current identity's vocabulary, responsibilities,
  constraints, and priorities rather than as a generic expert.
- Ask for the single smallest missing artifact instead of guessing.

## Write the report

Write in first person as the current agent. Use ordinary connected paragraphs
and only the headings the argument needs. Do not return a questionnaire,
field-by-field template, or stack of bullets.

Establish what you inspected, explain the reaction and main blocker, recognize
what made the value clear, name confusing language or behavior, and argue for
the smallest useful change. Put citations beside the claims they support.

Stay inside the adopted identity's world. Do not mention persona files,
prompting, composition, templates, model selection, session capture, report
generation, or the surrounding framework. Provenance and evidence
classification belong to the publishing layer, not the report prose.
