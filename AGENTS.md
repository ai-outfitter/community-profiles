# Authoring profiles in this catalog

## The body is the agent's prompt

A profile's markdown body composes directly into the system prompt of a
running agent. The agent reads it as its own instructions, at runtime, with
no narrator between.

Write the body as direct address. Say "You work issues assigned to you."
Never describe the profile from outside — "An agent that inherits this
profile…", "This practice defines…", "The inheriting profile supplies…" is
meta-commentary about the document, and in a composed prompt it is noise the
agent must read past on every wake. The running agent IS the agent; there is
no reader for whom the description is information.

This applies equally to abstract profiles (`abstract: true`) and to the
shared fragments in `prompts/` that agents glue in via
`append_system_prompt: [{file: ...}]`. Neither runs alone — the text still
ends up verbatim inside some running agent's prompt, so it speaks to that
agent, not about it.

Notes for maintainers — why a line exists, what it depends on, what breaks
without it — go in frontmatter comments (`# …` inside the YAML block), which
never reach the prompt. The split is:

| Surface | Audience | Voice |
| --- | --- | --- |
| Markdown body | The running agent | Direct address: "you" |
| `prompts/*.md` | The running agent | Direct address: "you" |
| Frontmatter comments | Catalog maintainers | Anything |
| `description:` | Humans browsing the catalog | Third person, one line |
| README entry | Humans browsing the catalog | Third person, one line |

## Fragments carry prose; profiles carry capability

Keep prose inline in a profile body when only that profile carries it. Move
prose to a fragment when two or more profiles carry it, or when it is a
cross-catalog contract that offline organization catalogs vendor. A vendored
copy counts as a carrier. Use a skill when the content is an on-demand
procedure rather than an always-on prompt.

Profiles carry capability in frontmatter: tools, MCP servers, skills,
extensions, and models. Fragments carry all shareable prose. A persona must
fit on one screen: frontmatter says what it can do, the append list says what
it knows, and the body says who it is.

Every fragment answers one question according to its filename prefix:

| Prefix | Question |
| --- | --- |
| `environment.*` | Where am I running? |
| `practice.*` | How do I work? |
| `prose.*` | How do I write? |

There is no `deployment.*` prefix. Fragments have no frontmatter and no
in-file provenance marker because any comment would compose into the running
agent's prompt. Vendor fragments as byte-identical whole files. Put provenance
in a frontmatter comment on the vendoring profile.

## Everything else

- One directory per profile: `agents/<slug>/agent.md`.
- `abstract: true` marks a composable that MUST NOT be run directly or set
  as `default_agent`; runnable profiles opt in with `inherits: [<slug>]`.
- Run `outfitter validate --strict` before opening a pull request.
- Keep `README.md`'s catalog list in sync: one line per profile.
