---
name: persona-review
description: Use when reviewing a product, docs, onboarding flow, or UX from the point of view of an assigned user/customer persona, returning a fixed comparable shape.
---

# Persona review

Review one artifact from the point of view of an assigned persona, and return
a fixed output shape so reviews from different personas stay directly
comparable. This is the [persona convention](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/personas.md):
this skill is the fixed *review method*; the persona is a swappable markdown
document you are told to adopt at run time. Adopting a different persona
document swaps the viewpoint; the method and output shape below never change.

## Adopt the persona

The persona reaches you as an appended prompt fragment (a document adopted at
run time) or is named directly in your launch prompt — either way, adopt the
documents **in order**:

1. A **role** file (`kind: role`) establishes the customer segment's shared
   priorities — its goals, anxieties, buying triggers, and what its feedback
   focuses on.
2. An **individual** file (`kind: individual`) layers one named person's
   demographics and voice on top. Later files refine earlier ones. If an
   individual names `roles:` in its frontmatter, treat those roles as its
   baseline — read them first even if the launch prompt did not name them
   separately.

Bundled starter personas tuned to Outfitter's own audience live under
`references/`; adopt any of them, or a persona document the launch prompt
points at elsewhere:

- Roles — [references/roles/platform-lead.md](references/roles/platform-lead.md),
  [references/roles/founder-operator.md](references/roles/founder-operator.md).
- Individuals — [references/individuals/priya-nair.md](references/individuals/priya-nair.md)
  (`roles: [platform-lead]`),
  [references/individuals/dana-okafor.md](references/individuals/dana-okafor.md)
  (`roles: [founder-operator]`).

## Review from that viewpoint

Read or experience the provided artifact strictly as that persona would:
docs, screenshots, a website, a prototype, a product flow, or an onboarding
path. Then:

- Distinguish **evidence** (something you actually read or saw) from
  **assumptions**, and label assumptions as assumptions.
- Cite the **exact page, section, or UI moment** that shaped each reaction.
- Do **not** invent real customer research, private facts, pricing, or
  production behavior. A persona is a decision aid, not synthetic validation.
- Stay in the persona's vocabulary and priorities; do not review as a
  generic expert.
- If you need more context, ask for the single smallest missing artifact
  rather than guessing.

## Return the fixed shape

Return exactly these fields, in this order, so every persona's review lines
up against every other:

1. **Persona** — the role + individual adopted.
2. **Artifact reviewed** — what you actually read/experienced.
3. **First impression** — the immediate reaction from this viewpoint.
4. **Top blocker** — the single thing most likely to stop this persona,
   with the cited moment that causes it.
5. **Strongest value signal** — the moment that most made the value land.
6. **Confusing language** — specific words/sections that read as jargon or
   were unclear to this persona.
7. **Suggested change** — the smallest change that would most improve this
   persona's outcome.
8. **Confidence** — high / medium / low, and why.

Because the shape is fixed here and not in the persona document, feedback
from different personas is directly comparable.

## Running a review as its own process

The cleanest way to adopt a persona is to spawn the composed reviewer as its
own process with the persona appended. `outfitter run <agent> -- <args>`
forwards pass-through args to the harness and appends them last, so the child
is the fully composed reviewer (its own system prompt, this skill, and the
profile's model) with the persona layered on top; the base agent stays fixed
and each persona run is isolated and comparable.

This skill bundles [scripts/persona-review.sh](scripts/persona-review.sh),
which resolves the persona document(s) you name and passes them through as
`--append-system-prompt`:

```bash
bash scripts/persona-review.sh \
  --persona references/roles/platform-lead.md \
  --persona references/individuals/priya-nair.md \
  -- --print "@docs/getting-started.md Return the standard persona-review shape."
```

That expands to
`outfitter run reviewer -- --append-system-prompt <role> --append-system-prompt <individual> --print "…"`.
Give the role first and the individual second so the individual refines the
role; attach the artifact with pi's `@`-syntax. Because the child is a composed
reviewer, it keeps the profile's model and skills — nothing to re-specify. Run
the script once per persona and compare the fixed-shape outputs side by side.

To do it ad hoc without the script — an agent can append any document on the
fly:

```bash
outfitter run reviewer -- \
  --append-system-prompt references/individuals/dana-okafor.md \
  --print "@docs/getting-started.md Return the standard persona-review shape."
```

When you already are the review agent (this skill is loaded), you can instead
adopt the persona document directly from your context and return the shape
yourself, without spawning a child — the script is for producing clean,
isolated, per-persona runs.
