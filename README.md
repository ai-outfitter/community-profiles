# Outfitter community agents

Community-contributed Dotagents catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Agents and skills here are reviewed for structure but are not curated like the [default catalog](https://github.com/ai-outfitter/default-profiles) — read an agent and its selected resources before you run it.

## Agents

- `actions-agent` - conventional headless identity for GitHub Actions automation.
- `founder` - owns the mission, priorities, constraints, and final decisions.
- `planner` - maintains plans, summarizes project status, delegates work, and writes daily reports. It does not implement changes.
- `engineer` - owns implementation and verification.
- `resident-engineer` - implements the exact assigned issue through a pull request; an independent identity reviews it and a maintainer merges it.
- `luce` - resident engineer with a planning, prose, and requirements-review emphasis.
- `vega` - resident engineer with a correctness, failure-mode, and test-review emphasis.
- `product-marketer` - owns outbound communication; turns merged change into user stories and release notes.
- `researcher` - produces sourced research, maintains durable knowledge, authors personas, and reviews artifacts from a persona. It does not select a runtime environment.
- `explorer` - maps repositories or systems in a read-only environment.
- `environment` - abstract repository location and authentication baseline for inherited agents.
- `environment.repos` - abstract repository checkout and worktree layout under `~/repos`: one clean clone on the default branch, all work in typed worktrees.
- `environment.agent-operator-pod` - abstract runtime context for resident agents in Kubernetes pods.
- `environment.actions-runner` - abstract runtime context for ephemeral CI agents.
- `environment.container-readonly` - abstract tool boundary for read-only agents.
- `environment.repo-auth` - abstract, replaceable repository transport and forge authentication convention.
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
- `code-review` - review a pull request diff against its issue's acceptance criteria; the reviewer approves or requests changes and a maintainer merges.
- `resident-contribution` - route one exact Channels Task into assigned-issue implementation, independent review, or a bounded thread answer.
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
- `practice.draft-pr-lifecycle` - author changes through a draft PR: iterate and verify CI drafted, mark ready when green, enable auto-merge via the merge queue, and re-request review after changes (engineer, product-marketer).
- `practice.adversarial-review` - review to find the failure; anchor findings as inline comments on real diff line numbers (code-review, engineer, product-marketer, luce).
- `practice.pull-request-approval` - grant a distinct resident reviewer authority to submit `APPROVE` on a clean current head while a maintainer owns merge (code-review, resident-engineer, luce, vega).
- `practice.resident-contribution` - route exact assignment and review Tasks across author, independent-reviewer, and maintainer ownership (resident-engineer, luce, vega).

The `resident-contribution` skill routes an exact Channels Task: an assigned
issue starts implementation through a reviewed pull request, while a review
request produces `REQUEST_CHANGES` or `APPROVE`. It is composed into
`resident-engineer`, `luce`, and `vega`; the author, reviewer, and maintainer
remain distinct roles.

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
The catalog enables all of its published workflow roots when used as the project `.agents` tree.
When using it only as a source, list the workflow roots you want in your own loaded settings;
source settings are intentionally not imported.

## Workflows

`workflows/<id>/workflow.yaml` contains the ten canonical, declarative workflow
graphs. All ten are explicitly enabled in `settings.yml`. Outfitter resolves
and validates their complete agent, skill, prompt, MCP, nested-workflow, and
pinned-artifact closure; it never executes workflow nodes. Publication is
blocked unless strict validation and two byte-identical exports of every root
succeed against Outfitter v1.14.0.

To validate against a local Outfitter build:

```sh
scripts/validate-workflows.sh /path/to/outfitter/code/cli/dist/cli.js
```

## Contributing an agent or skill

1. Add `agents/<id>/agent.md` with a matching `name`, a precise `description`, and the smallest useful loadout.
2. Keep durable policy in the agent and reusable procedures in `skills/<id>/SKILL.md`; prefer adding a skill over a near-duplicate agent.
3. A template profile (a capability bundle meant for composition, like `git-forge-delegator`) MUST NOT inherit other profiles; the runnable profile composes the full chain — see [Scaling by composition](docs/scaling-by-composition.md).
4. Select resources by slug from agent frontmatter. Keep Pi-only extensions explicit and pinned when reproducibility matters.
5. Run `outfitter validate --strict`, then open a pull request that names the intended harnesses (Pi or Claude Code).

Prefer opening an issue first: newly opened issues are triaged automatically by the conventional [`actions-agent`](agents/actions-agent/agent.md) and its selected [issue-triage skill](skills/issue-triage/SKILL.md) (running on this repo via [`ai-outfitter/actions`](https://github.com/ai-outfitter/actions), see [.github/workflows/issue-triage.yml](.github/workflows/issue-triage.yml)). The agent labels the issue `feat` (new agent, skill, or prompting change) or `fix`, and comments with a suggested plan and example sketches following Outfitter best practices. Issues it cannot classify confidently get no label — just a comment asking a maintainer to take a look.

## Layout

```text
agents/         one directory per agent identity and loadout
skills/         reusable Agent Skills packages
prompts/        shared prompt fragments appended by agents
workflows/      declarative workflow packages resolved by Outfitter
models.json     model/provider configuration used by the CI agent
settings.yml    Outfitter defaults for this standalone payload
```
