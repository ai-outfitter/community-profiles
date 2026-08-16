# Outfitter community agents

Community-contributed Dotagents catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Agents and skills here are reviewed for structure but are not curated like the [default catalog](https://github.com/ai-outfitter/default-profiles) — read an agent and its selected resources before you run it.

## Agents

- `actions-agent` - conventional headless identity for GitHub Actions automation.
- `founder` - owns the mission, priorities, constraints, and final decisions.
- `planner` - maintains plans, summarizes project status, delegates work, and writes daily reports. It does not implement changes.
- `engineer` - owns implementation and verification.
- `product-marketer` - owns outbound communication; turns merged change into user stories and release notes.
- `researcher` - produces sourced external research in a read-only environment; overlapping reviewer for code and prose (in-session verdicts).
- `explorer` - maps repositories or systems in a read-only environment.
- `environment` - portable repository location and authentication baseline for inherited agents.
- `environment.repos` - repository checkout and worktree layout under `~/repos`: one clean clone on the default branch, all work in typed worktrees. Requires outfitter >= 1.9.0 (dotted slugs).
- `agent-operator-pod` - runtime context for resident agents in Kubernetes pods.
- `actions-runner` - runtime context for ephemeral CI agents.
- `container-readonly` - tool boundary for read-only agents.
- `repo-auth` - replaceable repository transport and forge authentication convention.
- `git-forge-delegator` - creates and reviews delegated forge work. Template profile: compose it (`inherits: [environment, git-forge-delegator]`), do not run it directly — it no longer carries the repository and auth environment itself.
- `platform` - platform engineering setup for infrastructure, CI/CD, deployment, reliability, browser-debugging evidence, and developer tooling.
- `media-editor` - video post-production setup for transcript-driven editing with whisper.cpp and ffmpeg. See [docs/media-editor.md](docs/media-editor.md).
- `persona-reviewer` - one shared review profile whose identity is supplied by
  persona Markdown appended at launch.
- `grafana-agent` - platform agent for Grafana on Kubernetes: provisions the Grafana MCP securely and declaratively, and investigates firing alerts with read-only, comment-only diagnosis. Ships agent-local skills (`grafana-mcp-setup`, `grafana-alert-investigate`, `alert-issue-triage`) and a per-agent `mcp.json` merged into the composition. See [docs/grafana-agent.md](docs/grafana-agent.md).

## Skills

- `browser-mcp` - use Playwright or Chrome DevTools MCP for browser automation, UI debugging, screenshots, console/network inspection, and isolated browser sessions.
- `persona-authoring` - create a self-contained persona document whose details
  live in portable Markdown.
- `persona-review` - run one isolated shared reviewer with a canonical persona
  file and save a sourced report in the adopted voice.
- `media-editor` - transcript-driven video editing: toolchain setup, whisper.cpp transcription, and ffmpeg cut/speed/export, with per-step references.
- `pyramid-principle` - structure ideas, documents, and communications top-down (conclusion first) for clarity.
- `code-review` - review a pull request diff against its issue's acceptance criteria; approve, request changes, or merge when green.
- `prose-review` - review prose artifacts for thesis, structure, and register before they publish or merge.
- `issue-triage` - classify and comment on new GitHub issues.
- `mermaid` - generate Mermaid diagrams across 20+ diagram types, routing to a per-type syntax reference. Vendored from [WH-2099/mermaid-skill](https://github.com/WH-2099/mermaid-skill) (MIT).
- `project-daily-report` - collect project and telemetry evidence, write a linked daily Markdown report, and publish one idempotent edition.
- `slidev` - scaffold a minimal Slidev deck: package.json, slides.md, dev/build/PDF-export scripts. Setup only.
- `storyboard` - sequence a story into beats, each pairing a claim, a prose line, and an image prompt, written as storyboard.md before deck or one-pager work.
- `replicad` - code-CAD with replicad v0.19 on the OpenCASCADE B-rep WASM kernel: parts as functions, subassemblies, STL/STEP export, and a minimal side-by-side HTML viewer.

## Prompts

Shared prompt fragments in `prompts/`, appended by agents via
`append_system_prompt: [{file: ...}]`:

- `prose.simplified-technical-english` - the succinct ASD-STE100 base register (engineer, planner).
- `prose.rfc2119-requirements` - requirements and acceptance criteria with RFC 2119 keywords (planner, founder, git-forge-delegator).
- `practice.draft-pr-lifecycle` - author changes through a draft PR: iterate and verify CI drafted, mark ready when green, enable auto-merge via the merge queue (engineer, product-marketer).
- `practice.adversarial-review` - review to find the failure; anchor findings as inline comments on real diff line numbers (engineer, product-marketer).

See [Persona documents and reviews](docs/persona-review.md) for the setup and
runtime boundary.

See [Environment baseline](docs/environment.md) for the composable repository
convention and the role-family boundaries.

See [Scaling by composition](docs/scaling-by-composition.md) for how an
organization grows this catalog's roles: skills first, then resident fission
with forge-mediated coordination.

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
3. A template profile (a capability bundle meant for composition, like `git-forge-delegator`) MUST NOT inherit other profiles; the runnable profile composes the full chain — see [Scaling by composition](docs/scaling-by-composition.md).
4. Select resources by slug from agent frontmatter. Keep Pi-only extensions explicit and pinned when reproducibility matters.
5. Run `outfitter validate --strict`, then open a pull request that names the intended harnesses (Pi, Claude Code, or Codex).

Prefer opening an issue first: newly opened issues are triaged automatically by the conventional [`actions-agent`](agents/actions-agent/agent.md) and its selected [issue-triage skill](skills/issue-triage/SKILL.md) (running on this repo via [`ai-outfitter/actions`](https://github.com/ai-outfitter/actions), see [.github/workflows/issue-triage.yml](.github/workflows/issue-triage.yml)). The agent labels the issue `feat` (new agent, skill, or prompting change) or `fix`, and comments with a suggested plan and example sketches following Outfitter best practices. Issues it cannot classify confidently get no label — just a comment asking a maintainer to take a look.

## Layout

```text
agents/         one directory per agent identity and loadout
skills/         reusable Agent Skills packages
prompts/        shared prompt fragments appended by agents
mcp.json        harness-neutral MCP server catalog
models.json     model/provider configuration used by the CI agent
settings.yml    Outfitter defaults for this standalone payload
```
