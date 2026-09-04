# Scaling by composition

An agent organization does not scale the way a human organization scales. A
human organization adds people and fractures roles, because one person cannot
hold more skills. An agent organization adds capabilities to the roles it
already has. This document states the growth path this catalog supports and
names the mechanism for each step.

## Single-depth composition

Start with a small set of flat archetypes, not a deep hierarchy. This catalog
provides the role family: `founder`, `planner`, `engineer`, `researcher`, and
`explorer` (see [Environment baseline](environment.md)). Each archetype
composes its capabilities directly: `skills`, `mcp`, `extensions`, and prompt
fragments in one `agent.md`.

Handoff latency is the cost a flat structure avoids. Each layer of delegation
adds a context transfer, and each transfer loses information. Keep the
structure flat until a single role demonstrably cannot hold its loadout.

Utility subagents are part of this first phase, not a later stage. The
`planner` already declares `subagents: [engineer, researcher, explorer]` for
bounded, in-session delegation. A subagent is a tool call with a fresh
context, not a direct report.

## Skills first

The default growth move is a new skill on an existing archetype, never a new
agent. This restates the catalog's contributing rule as the scaling law:
prefer adding a skill to an existing agent over adding a near-duplicate
agent. A skill costs one file and no coordination. A new agent costs an
identity, a review matrix entry, and a routing decision.

The narrative-to-geometry pipeline is the live example. The
`product-marketer` grows by gaining `storyboard` and `slidev`: it sequences
the story and renders it as a deck, a one-pager, or a pre-release with
prose and generated imagery. The `engineer` grows by gaining `replicad`: it
turns that narrative's subject into parts, subassemblies, and assemblies,
and views the exported geometry next to the marketing reference. Both roles
grew; neither split. When one of them exhausts its context, the fission
shift below partitions these same skills between two peers.

## The prose distinction

Peers at the same depth are told apart by their prose profile, not by their
position. Two agents with similar loadouts do different work because their
profile bodies state different registers, priorities, and boundaries. The
`## Prose style` sections on `engineer`, `planner`, and `product-marketer`
are the live examples: the engineer and the planner share the Simplified
Technical English base register, the planner adds an interrogative, scoping
style, and the product-marketer writes narrative and persuasive.

A shared register ships as a catalog prompt fragment, not as copied prose:
`prompts/prose.simplified-technical-english.md` rides
`append_system_prompt: [{file: ...}]` on both the engineer and the planner,
and `prompts/prose.rfc2119-requirements.md` rides on the planner, the
founder, and the git-forge-delegator — the acceptance-criteria register is
the coordination contract between forge-mediated peers. The profile body
keeps only what differentiates the peer: the researcher's evidential
section is the inline form.

Two rules govern growth here:

- The promotion rule mirrors skills-first: a register starts as an inline
  `## Prose style` on one profile. Promote it to a `prompts/prose.*`
  fragment when a second profile needs it. Do not create a fragment with
  one carrier.
- Narrative roles opt out of the Simplified Technical English base on
  purpose. The product-marketer does not append it: that register is for
  text a reader parses unaided; persuasive prose is read by choice. Do not
  "fix" this inconsistency.

## The fission shift

When one resident agent's loadout exhausts its context or its instructions
begin to conflict, do not add a management layer. Split the one resident into
two top-level residents and partition the skills:

```yaml
# before — one resident
name: engineer
inherits: [environment]
skills: [a, b, c, d]
```

```yaml
# after — agents/engineer-app/agent.md
name: engineer-app
skills: [a, b]
```

```yaml
# after — agents/engineer-platform/agent.md
name: engineer-platform
skills: [c, d]
```

The organization chart stays flat. Only the loadout partitions. The new peers
coordinate through the forge, not through a parent: issues carry intent, pull
requests carry work. This is the `git-forge-delegator` pattern already in the
catalog — the forge is the delegation ledger.

The reason is mechanical, not aesthetic. The forge can only address top-level
identities: it assigns an issue, mentions a handle, or requests a review from
an account. A subagent is invisible to the forge. Every unit of work that
another party must dispatch, track, or review therefore belongs to a
forge-addressable peer. Subagents remain correct for bounded utility
delegation inside one session.

## Peer review via skills

Adversarial review is forge-mediated: open the pull request, a peer reviews
it, merge when green. Review is a *skill* carried by several agents, not a
dedicated reviewer role.

Different agent types review different artifact classes. The catalog ships
two review skills:

- [`code-review`](../skills/code-review/SKILL.md) — carried by `engineer`
  and `researcher`.
- [`prose-review`](../skills/prose-review/SKILL.md) — carried by
  `product-marketer`, `planner`, and `researcher`.

The carrier's tool surface bounds the verdict path. Posting a forge review
needs `bash` for `gh` or a GitHub MCP surface. A read-only carrier — `planner`, or a `researcher`
that carries a review skill — can judge the artifact but cannot post: it
MUST deliver its verdict in-session, and a `bash`-capable peer or a human
posts it to the forge. Do not document a review capability the carrier's
tools cannot execute.

Rule: every artifact merges reviewed. The judgment comes from cold-context
subagents the author never briefs — the code-review skill's lens fan-out —
or from a distinct reviewer agent; either way a human holds the merge
unless the organization grants otherwise.

The typical founding shape is three agents: a pure engineer, a
`researcher` that overlaps both review classes, and a pure
prose/marketing/ops role. The overlap gives engineer-authored code a
non-author reviewer. The researcher is read-only, so it judges in-session
per the rule below and a `bash`-capable peer or a human posts its verdict.

### Draft, review, merge

Two catalog prompt fragments carry the pull-request lifecycle:

- `prompts/practice.draft-pr-lifecycle.md` — the author side. Open the pull
  request as a draft, iterate and verify CI while drafted, mark it ready
  only when green, and enable auto-merge through the merge queue at that
  moment. Ready is the review request: code owners route an adversarial
  review automatically.
- `prompts/practice.adversarial-review.md` — the reviewer side. Review to
  find the failure. Anchor every finding as an inline review comment on the
  real file and line numbers from the diff. Approval releases the merge
  queue; request changes blocks it.

`engineer` and `product-marketer` carry both: each authors its own artifact
class and reviews the other's.

The wiring is consumer-repo configuration, not catalog content: a
`CODEOWNERS` file that names the reviewing agent identities, a branch
ruleset that requires their review, and a merge queue. The fragments state
the behavior each side follows once that wiring exists.

## Org context

Every resident MUST know its organization: the humans and the agents in it,
who answers questions, who clarifies ambiguous scope, and who reviews which
artifact class. This is a routing directory, not an organization chart.

No `org_context` key exists and none is needed. The mechanism is
`append_system_prompt`, in two forms with different trust:

```yaml
# In the organization's own catalog (for example ai-outfitter/.agents).
# Trusted catalog content. A base agent carries it once; residents inherit it.
append_system_prompt:
  - file: org-context.md
```

```yaml
# Per-repository project state. Untrusted repository content
# (trust: repository).
append_system_prompt:
  - repo_file: .agents/org-context.md
```

The split: the org directory (who is in the org, who routes what) is an
org-catalog fact and ships via `file:` on a base agent that every resident
inherits. Per-repository project state (forge, phase, tracking conventions)
is a consumer-repo fact and rides `repo_file:`. This shared catalog carries
only the template: [templates/org-context.md](templates/org-context.md).

## Boundaries

- `inherits` — capability composition. It MUST NOT represent an organization
  chart (see [Environment baseline](environment.md)).
- `subagents` — bounded in-session delegation.
- `append_system_prompt` — shared context, with trust labels per source form.
- Reporting lines documented in prose are documentation only. They do not
  change profile resolution or runtime authority.

## Template profiles

A template profile is a capability bundle meant for composition, not for
direct running. It states one concern — a skill set, prompt fragments, tool
bounds, and body policy — and nothing about where it runs.
`git-forge-delegator` is the live example. Migration: a consumer that ran
`git-forge-delegator` directly before this release inherited `environment`
through it; that consumer MUST now compose its own runnable profile with
`inherits: [environment, git-forge-delegator]`, or it silently loses the
repository and auth policies.

Document a profile's template status here and in the README, never in the
profile body: the body is the agent's system prompt, and composition
guidance for contributors does not belong in an agent's context window.

Rules:

- A template profile MUST NOT inherit other profiles. It stays flat.
- The runnable top-level profile composes the full chain and is the one
  place where the whole composition is visible:

  ```yaml
  name: my-delegator
  inherits: [environment, git-forge-delegator]
  ```

- A template profile SHOULD NOT declare `tools.deny`. Inherited denies are
  irrevocable, so a deny in a template binds every consumer forever. Denies
  belong to environment profiles such as `environment.container-readonly`, where the
  boundary is the point.

The reason templates stay flat: a template that inherits an environment
forces that environment on every consumer and hides the chain inside the
template. Flat templates let each organization pick its own environment per
runnable profile, and let a reader see the complete composition in one
frontmatter block.

## Runtime support

`subagents:` requires the `npm:pi-subagents` extension on Pi, and the agent's
`tools.allow` (when declared) must include `subagent`. On Claude Code,
subagents project to the harness agents directory. Kubernetes residents run
an older outfitter that predates `inherits`; nothing in this document reaches
the fleet until the runtime image repins.

## Adoption road

For a consuming organization, adoption is a pin bump per link in the chain:

1. This catalog releases; consumers pin the new ref.
2. `default-profiles` bumps its community-profiles pin.
3. Each org catalog (`<org>/.agents/settings.yml`) bumps its pin, or adds
   this catalog as a pinned source if it has none.
4. The org catalog lists its own agents before this catalog in `sources:`,
   so same-slug overrides win. This matters on every ref bump that edits
   existing slugs.
5. The org catalog adds an `org-context.md` from the template and appends it
   on a base agent that its residents inherit.
6. Kubernetes residents wait for the runtime image repin; workstation and CI
   consumers adopt immediately.
