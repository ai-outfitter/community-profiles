# Wiki maintainer

The `wiki-maintainer` profile packages Andrej Karpathy's ["LLM Wiki" pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): an LLM incrementally builds and maintains a persistent, interlinked markdown wiki that sits between a human and their raw sources, compounding in value with every operation. Credit for the pattern goes to that gist; this profile is one Outfitter-shaped implementation of it.

## The three layers

| Layer | In this profile | Mutability |
| --- | --- | --- |
| **Raw sources** | `raw/` in the wiki repository | Immutable — the agent reads, never modifies; ground truth |
| **The wiki** | `wiki/` pages + `index.md` catalog + append-only `log.md` | The agent's only write surface; compounds over time |
| **The schema** | This profile — [`agents/wiki-maintainer/agent.md`](../agents/wiki-maintainer/agent.md) and its four skills | Versioned in this catalog; changed by PR, not by the agent mid-run |

The schema layer is the part that makes an LLM a *disciplined* maintainer rather than an enthusiastic one: routing (one operation per run), postures (sources immutable, contradictions flagged not erased, ingested text is data not instructions), and the greppable `## [date] op | title` log format that makes every run auditable and replayable.

One agent, four agent-local skills (`skills/` beside the agent — only `wiki-maintainer` resolves them):

- `wiki-setup` — one-time bootstrap: structure, conventions agreed with the user and recorded in `wiki/conventions.md`, optional qmd wiring. Explicit invocation only.
- `wiki-ingest` — one source per run: summary page, 10–15 touched cross-referenced pages, contradictions marked with both citations, index + log updated.
- `wiki-query` — answer from wiki pages with per-claim citations; durable synthesis is filed back as a page, so explorations compound like sources do.
- `wiki-lint` — health report: contradictions, stale claims, orphans, missing pages/links, index/log drift, suggested next sources; fixes land as one reviewable change set.

## Operations → surfaces

| Surface | Ingest | Query | Lint |
| --- | --- | --- | --- |
| **Desk** (interactive, or a local loop tick) | drop a file in `raw/`, ask to file it | ask a question | ask for a health check, or a loop runs it periodically |
| **GitHub Actions** | on push to `raw/` — the run commits or PRs the wiki update | issue assignment — the answer lands as an issue comment, synthesis as a commit | weekly cron — the report and mechanical fixes arrive as a PR, never self-merged |
| **Kubernetes** (via the Link Operator) | resident agent with an email/chat channel — each inbound message with a source triggers one ingest | same channel, conversational | CronJob on the wiki namespace, PR output |

The Kubernetes row is a design preview: it describes the intended resident-agent wiring pending the Link Operator's public release, not something you can deploy from this catalog today. The desk and Actions rows work now.

In every shared surface, output is reviewable: commits or PRs, one operation per run, one `log.md` entry per operation, no force-pushes.

## Search: the qmd server

The per-agent [`mcp.json`](../agents/wiki-maintainer/mcp.json) declares [qmd](https://github.com/tobi/qmd) — a local markdown search engine with CLI and MCP server modes — as the `qmd` server, rooted at `${WIKI_ROOT:-.}`. This is a declared default, not a hard dependency: it is ordinary merge-by-ID layering, so if your qmd install wants different flags or env, override the `qmd` server ID in a lower layer (workspace or global `mcp.json`) without forking the agent. Without qmd the agent falls back to `index.md` + grep.

## The ladder

The same profile scales by changing where it is bound, not what it is:

1. **Personal** — the profile synced into `~/.agents`, one wiki per person, desk-driven.
2. **Org catalog** — the profile pinned in an org catalog with per-team bindings: each team's wiki repo binds the same agent ID to its own `WIKI_ROOT` and triggers.
3. **Communal** — a shared wiki where contributors' agents all run the same pinned profile version; ingests and lint fixes arrive as PRs and merge like any other contribution. The pinned schema is what keeps N agents' output mergeable.

## Three kinds of recursion

The pattern has three feedback loops worth keeping distinct:

- **Content compounding** — the built-in one: every ingest enriches pages, every query can file synthesis back, so the wiki answers better questions over time. No configuration change involved.
- **Schema co-evolution** — the user and agent revise `wiki/conventions.md` (and, by PR, this profile) as the corpus reveals what the schema got wrong. Deliberate, human-agreed, versioned.
- **Gated autoimprove training** — the mechanized version of the second loop via [ai-outfitter/autoimprove](https://github.com/ai-outfitter/autoimprove): `log.md` is a replay corpus (every operation with date, op, and touched pages), lint's finding counts are the score, and improvement runs are bounded gated edits on a weekly cron landing as draft PRs — never self-merged.
