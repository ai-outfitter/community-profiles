# Outfitter community agents

Community-contributed Dotagents catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Agents and skills here are reviewed for structure but are not curated like the [default catalog](https://github.com/ai-outfitter/default-profiles) — read an agent and its selected resources before you run it.

## Agents

- `actions` - default headless identity for GitHub Actions, Forgejo Actions, and Gitea Actions automation, including step-level job-failure diagnosis and bounded repair.
- `media-editor` - video post-production setup for transcript-driven editing with whisper.cpp and ffmpeg. See [docs/media-editor.md](docs/media-editor.md).

## Skills

- `media-editor` - transcript-driven video editing: toolchain setup, whisper.cpp transcription, and ffmpeg cut/speed/export, with per-step references.
- `pyramid-principle` - structure ideas, documents, and communications top-down (conclusion first) for clarity.
- `actions/actions-automation` - agent-local cross-forge Actions event handling; its first runbook handles a final `if: failure()` step by commenting with a diagnosis or applying an explicitly authorized bounded repair.
- `actions/issue-triage` - agent-local classification and commenting for new GitHub issues.

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
2. Put a capability used only by that agent in `agents/<id>/skills/<skill-id>/`; publish genuinely reusable capabilities in `skills/<skill-id>/`. Keep durable policy in the agent and prefer adding a skill over a near-duplicate agent.
3. Select resources by slug from agent frontmatter. Keep Pi-only extensions explicit and pinned when reproducibility matters.
4. Run `outfitter validate --strict`, then open a pull request that names the intended harnesses (Pi or Claude Code).

Prefer opening an issue first: newly opened issues are triaged automatically by the conventional [`actions`](agents/actions/agent.md) agent and its selected [agent-local issue-triage skill](agents/actions/skills/issue-triage/SKILL.md) (running on this repo via [`ai-outfitter/actions`](https://github.com/ai-outfitter/actions), see [.github/workflows/issue-triage.yml](.github/workflows/issue-triage.yml)). The agent labels the issue `feat` (new agent, skill, or prompting change) or `fix`, and comments with a suggested plan and example sketches following Outfitter best practices. Issues it cannot classify confidently get no label — just a comment asking a maintainer to take a look.

## Layout

```text
agents/                 one directory per agent identity and loadout
  <agent>/skills/       skills private to that agent's loadout
  <agent>/hooks/        hooks private to that agent (proposed protocol entity)
skills/                 reusable catalog-wide Agent Skills packages
.github/models.json     GitHub Models provider used only by this catalog's CI
settings.yml    Outfitter defaults for this standalone payload
```
