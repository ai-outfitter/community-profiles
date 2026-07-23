---
name: wiki-setup
description: >-
  Bootstrap a wiki repository for the wiki-maintainer — create the raw/ and
  wiki/ layers, index.md and log.md, agree schema conventions with the user,
  and optionally wire up qmd search. Only ever run when explicitly requested.
---

# Wiki setup

You are bootstrapping a wiki repository once. This skill never runs from a
trigger or a schedule — only when the user explicitly asks for a new wiki or
asks to retrofit an existing pile of markdown.

## 1. Lay down the structure

Create, inside the directory the user designates as the wiki root:

```text
raw/          immutable sources — you will read here, never write
wiki/         your pages — the only write surface
index.md      catalog of every wiki page, one line each: path, title, one-phrase summary
log.md        append-only operation history
```

Seed `index.md` with a header explaining its format and `log.md` with its
first entry: `## [YYYY-MM-DD] setup | wiki initialized`.

## 2. Agree the schema with the user

The schema is a conversation, not a decree. Propose defaults and let the user
adjust before writing anything down:

- **Page frontmatter** — suggest `title`, `created`, `updated`, `sources`
  (paths into `raw/`), `tags`. Keep it minimal; every field must earn its keep.
- **Naming** — lowercase-hyphenated filenames, one entity or concept per page.
- **Categories** — a short starting list (people, projects, concepts, sources,
  syntheses) sized to the user's actual material, not a taxonomy fantasy.
- **Linking** — relative markdown links between pages; every page should be
  reachable from `index.md`.

## 3. Optionally wire up qmd

If the user wants search beyond grep, install [qmd](https://github.com/tobi/qmd)
and confirm the agent's `mcp.json` resolves: the `qmd` MCP server reads its
root from `WIKI_ROOT` in the environment. Do not hardcode a machine path
anywhere in the tree; the environment supplies it. If the user declines, note
in conventions that search is `index.md` + grep — the wiki works either way.

## 4. Record the conventions in the wiki itself

Write the agreed schema to `wiki/conventions.md` and add it to `index.md`.
This page is the contract future runs consult before writing — frontmatter
fields, naming, categories, and the log entry format
(`## [YYYY-MM-DD] <op> | <title>`). When conventions later change, they change
on that page first, by agreement with the user, never silently mid-operation.

Finish by appending the setup entry to `log.md` and showing the user the tree
you created.
