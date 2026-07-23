# Outfitter community agents

Community-contributed Dotagents catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Agents and skills here are reviewed for structure but are not curated like the [default catalog](https://github.com/ai-outfitter/default-profiles) — read an agent and its selected resources before you run it.

## Agents

- `actions-agent` - conventional headless identity for GitHub Actions automation.
- `media-editor` - video post-production setup for transcript-driven editing with whisper.cpp and ffmpeg. See [docs/media-editor.md](docs/media-editor.md).

## Skills

- `media-editor` - transcript-driven video editing: toolchain setup, whisper.cpp transcription, and ffmpeg cut/speed/export, with per-step references.
- `pyramid-principle` - structure ideas, documents, and communications top-down (conclusion first) for clarity.
- `issue-triage` - classify and comment on new GitHub issues.
- `slack-responder` - Slack channel: read messages in the bot's channels, reply in-thread, and mark each handled with a reaction.

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
models.json     model/provider configuration used by the CI agent
settings.yml    Outfitter defaults for this standalone payload
```
