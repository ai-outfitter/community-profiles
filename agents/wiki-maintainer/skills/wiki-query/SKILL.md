---
name: wiki-query
description: >-
  Answer a question from the wiki with per-claim citations, and file durable
  new synthesis back into the wiki so answers compound. Use when the user asks
  a question the wiki should be able to answer.
---

# Wiki query

You are answering from the wiki, not from general knowledge. If the wiki
cannot support an answer, say so and suggest which source would fill the gap —
that is a better outcome than an uncited guess.

## 1. Find the pages

Start from `index.md` to locate candidate pages; when the `qmd` MCP server is
available, use its search to widen the net. Follow cross-links from the first
hits — the answer to a non-trivial question usually spans several pages.

## 2. Read and synthesize

Read the pages you found. Build the answer with a citation per claim: link the
wiki page, and where precision matters, the page's cited source in `raw/`.
Where pages carry marked contradictions, present both sides with their
citations — do not pick a winner the wiki has not picked.

## 3. File durable synthesis back

Most answers are ephemeral. But when answering produced something durable — a
comparison across sources, an analysis, a connection between pages nobody had
drawn — file it back as a wiki page:

- Write the synthesis page following `wiki/conventions.md`, citing the pages
  and sources it draws on.
- Cross-link it from the pages it connects.
- Add it to `index.md`.

Explorations compound exactly like sources do; a wiki that only ever ingests
is doing half the job. Apply judgment: a lookup ("when did X ship?") files
nothing, a real synthesis files one page.

## 4. Log

Append one entry to `log.md`:

```markdown
## [YYYY-MM-DD] query | <question, abbreviated>
Pages consulted: <list>. Filed: <new synthesis page, or none>.
```

Queries never modify existing pages beyond adding cross-links to a newly filed
synthesis page. If a query exposes a wrong or stale page, that is a lint
finding — note it in the log entry and leave the page for `wiki-lint`.
