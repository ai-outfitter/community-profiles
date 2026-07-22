# Persona review

The `reviewer` agent is a general base review agent that gathers structured
feedback on a product, docs, onboarding flow, or UX from the point of view of
an assigned user or customer persona. It names no customer type itself — it
adopts whichever persona documents you feed it at run time, so one agent
covers many viewpoints.

It uses the [persona convention](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/usecases/persona-reviews.md):
one fixed base review agent plus interchangeable persona description
documents, run once per document. There is no agent per customer type.

## Bundled skill

The agent selects a single Dotagents skill, `persona-review`, which holds the
fixed review method and output shape and bundles starter persona documents
tuned to Outfitter's own audience:

```text
agents/reviewer/skills/persona-review/
  SKILL.md
  references/
    roles/
      platform-lead.md
      founder-operator.md
    individuals/
      priya-nair.md        # roles: [platform-lead]
      dana-okafor.md       # roles: [founder-operator]
```

Personas come in two kinds of file you **mix and match**: a `kind: role`
carries the priorities everyone in a customer segment shares, and a
`kind: individual` is one named person who inherits one or more roles and
adds their own demographics and voice.

## Output shape

Because the shape is fixed in the skill and not in the persona document,
feedback from every persona is directly comparable. Each review returns:
persona, artifact reviewed, first impression, top blocker, strongest value
signal, confusing language, suggested change, and confidence.

## Creating a persona

To add a new viewpoint, author a persona document from the templates in the
skill's `assets/` directory and save it under `references/`:

- **A role** (`kind: role`) — a reusable customer segment. Copy
  `assets/template.role.md` to `references/roles/<slug>.md` and fill `title`,
  `segment`, `goals`, `anxieties`, `buying_triggers`, and `feedback_focus`, plus
  a paragraph describing the segment.
- **A person** (`kind: individual`) — one named human who inherits roles. Copy
  `assets/template.person.md` to `references/individuals/<slug>.md`, set `roles:`
  to existing role slug(s), and fill `name`, `born`, `location`,
  `household_income`, `education`, `employer`, `hobbies`, `skills`, and `tone`,
  plus a paragraph of background and voice.

`<slug>` is the lowercase, hyphen-separated name (`Dana Okafor` → `dana-okafor`);
author the role first if the person's segment has none. The `reviewer` agent can
do this interactively — ask it to create a persona and it walks the template
fields (see the skill's **Create a persona** section) — or copy the templates by
hand. Once saved, adopt the new persona in a review exactly like the bundled ones.

## Running a one-off review

Each persona review runs as its own composed reviewer process with the persona
appended — no Outfitter changes needed, because `outfitter run <agent> -- …`
forwards pass-through args to the harness and appends them last. The skill
bundles
[`scripts/persona-review.sh`](../agents/reviewer/skills/persona-review/scripts/persona-review.sh),
which resolves the persona document(s) and passes them through as
`--append-system-prompt`. From the skill directory:

```bash
bash scripts/persona-review.sh \
  --persona references/roles/platform-lead.md \
  --persona references/individuals/priya-nair.md \
  -- --print "Return the standard persona-review shape. \
     @outfitter/docs/documentation/first-time-cli-agent-users.md"
```

That expands to `outfitter run reviewer -- --append-system-prompt <role>
--append-system-prompt <individual> --print "…"`. Give the role first and the
individual second (the individual refines the role) and attach the artifact
with pi's `@`-syntax — put the `@path` **last** in the prompt, since pi reads an
`@` reference to the end of the string. Swap in `founder-operator` + `dana-okafor` to review the
same artifact from another viewpoint; because the output shape is fixed, the
runs line up side by side. Since the child is a composed reviewer, it keeps the
profile's model and skills — nothing to re-specify.

You normally reach this through the `reviewer` agent — it invokes the script
for you and relays the result — but any agent that loads the `persona-review`
skill can call the script directly, or append a document ad hoc with
`outfitter run reviewer -- --append-system-prompt <doc> --print "…"`.

`--persona` (and `--append-system-prompt`) accepts **any** document path, not
just the bundled `references/` — so this is also the one-off path: point it at a
persona you wrote anywhere on disk and review against it immediately, without
saving it into the catalog.
