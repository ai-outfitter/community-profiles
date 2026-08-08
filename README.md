# Outfitter community agents

Community-contributed Dotagents catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Agents and skills here are reviewed for structure but are not curated like the [default catalog](https://github.com/ai-outfitter/default-profiles) — read an agent and its selected resources before you run it.

## Agents

- `actions-agent` - conventional headless identity for GitHub Actions automation.
- `platform` - platform engineering setup for infrastructure, CI/CD, deployment, reliability, browser-debugging evidence, and developer tooling.
- `media-editor` - video post-production setup for transcript-driven editing with whisper.cpp and ffmpeg. See [docs/media-editor.md](docs/media-editor.md).
- `persona-reviewer` - one shared review profile whose identity is supplied by
  persona Markdown appended at launch.

## Skills

- `browser-mcp` - use Playwright or Chrome DevTools MCP for browser automation, UI debugging, screenshots, console/network inspection, and isolated browser sessions.
- `persona-authoring` - create a self-contained persona document whose details
  live in portable Markdown.
- `persona-review` - run one isolated shared reviewer with a canonical persona
  file and save a sourced report in the adopted voice.
- `media-editor` - transcript-driven video editing: toolchain setup, whisper.cpp transcription, and ffmpeg cut/speed/export, with per-step references.
- `pyramid-principle` - structure ideas, documents, and communications top-down (conclusion first) for clarity.
- `issue-triage` - classify and comment on new GitHub issues.

See [Persona documents and reviews](docs/persona-review.md) for the setup and
runtime boundary.

## MCP servers

The tree-root `mcp.json` declares adoptable MCP servers. An agent adopts a server when its loadout lists the server id in the `mcp` field.

- `google-gmail`, `google-calendar`, `google-contacts` - official Google-hosted Workspace remote MCP servers (Developer Preview). Interactive sessions only; setup and security boundaries in [docs/google-workspace-mcp.md](docs/google-workspace-mcp.md).

## Using this catalog

Add the standalone catalog as a source and sync:

```yaml
# ~/.agents/settings.yml
sources:
  - github: ai-outfitter/community-profiles
    ref: <tag-or-commit>
```

```sh
outfitter sync
outfitter run <agent-id>
```

Pin `ref` to a tag or commit — an unpinned source runs whatever the catalog publishes next.

## Contributing an agent or skill

1. Add `agents/<id>/agent.md` with a matching `name`, a precise `description`, and the smallest useful loadout.
2. Keep durable policy in the agent and reusable procedures in `skills/<id>/SKILL.md`; prefer adding a skill over a near-duplicate agent.
3. Select resources by slug from agent frontmatter. Keep Pi-only extensions explicit and pinned when reproducibility matters.
4. Run `outfitter validate --strict`, then open a pull request that names the intended harnesses (Pi or Claude Code).

Prefer opening an issue first: newly opened issues are triaged automatically by the conventional [`actions-agent`](agents/actions-agent/agent.md) and its selected [issue-triage skill](skills/issue-triage/SKILL.md) (running on this repo via [`ai-outfitter/actions`](https://github.com/ai-outfitter/actions), see [.github/workflows/issue-triage.yml](.github/workflows/issue-triage.yml)). The agent labels the issue `feat` (new agent, skill, or prompting change) or `fix`, and comments with a suggested plan and example sketches following Outfitter best practices. Issues it cannot classify confidently get no label — just a comment asking a maintainer to take a look.

## Layout

```text
agents/         one directory per agent identity and loadout
skills/         reusable Agent Skills packages
mcp.json        adoptable MCP server declarations
models.json     model/provider configuration used by the CI agent
settings.yml    Outfitter defaults for this standalone payload
```
