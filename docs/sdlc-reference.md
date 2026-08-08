# SDLC reference collection

A canonical, adoptable configuration for an agentic software development
lifecycle: four agents, two declarative workflows, and one git-forge
governance policy. Copy it, then edit the data — the reviewer team, the
backend list, the repo targeting — to fit your organization.

## What works today

Each resource kind in this collection has a different maturity. The honest
support matrix:

| Resource | Status today |
| --- | --- |
| `agents/sdlc-*` | **Runnable.** Plain Dotagents agents. `outfitter run sdlc-planner` works now; `sdlc-explorer` is selectable as a subagent from any agent in your own catalog. |
| `governance/sdlc-baseline.yaml` | **Readable.** The `sdlc-report` skill can diff repositories against it (read-only conformance). An apply/converge command comes later. |
| `workflows/*.yaml` | **Validated only.** Schema-checked in CI against `spec/agent-workflow.v1.schema.json`; no runtime executes them yet. They freeze the authored surface for the workflow compiler and serve as its future conformance fixtures. |

## The agents

- **sdlc-explorer** — read-only scout subagent: one question in, conclusions
  with `file:line` references out. Never edits, executes, or reaches the
  network.
- **sdlc-planner** — read-only planner that fans out explorers and posts an
  implementation plan on a draft PR. The plan is its only artifact.
- **sdlc-reviewer** — read-only adversarial reviewer that verifies a change
  against its plan and posts findings. Never edits or merges.
- **sdlc-engineer** — implements a planned change on a draft PR branch, tests
  before pushing, never merges.

Permissions live on the agents, not in the workflows: a workflow step names
an agent; the agent's loadout is what it may touch. Restricting a planning
step to read-only is done by giving the step a read-only agent.

## The workflows

`agent-workflow/v1` is a flat sequence of steps. Each step is either an
`agent` invocation, a deterministic `run` command, or an `emit` that ends the
run with the workflow's typed output. Steps share one workspace and run in
order; `if:` conditions are enum-equality checks over prior step outputs, and
a `runs-on:` that references a decision step's enum selects an execution
backend per run.

- `feature-request` — assigned issue → draft PR → posted plan → routed
  implementation (local / copilot / kube-agent / actions) → adversarial
  review → ready-for-human-review with reviewers assigned, or a terminal
  `revision-requested` / `blocked-prerequisites` record.
- `vulnerability-fix` — vulnerability-labeled issue → affected/not-affected
  assessment → patch → review → ready-for-human-review, or a terminal
  `not-affected` / `revision-requested` record.

The decision-step convention: `bin/rank-implementers` prints JSON conforming
to the step's output schema. Because the contract is the schema, a shell
script and an LLM one-shot are interchangeable behind it, and every routing
decision is recorded output — evaluable later.

## The governance policy

`git-forge-governance/v1` declares what must be true of a repository for
agent workflows to be meaningful there: branch protection, capability caps on
agent identities, reviewer team requirements, evidence gates. It ships in
`warn` mode — runs proceed, non-conformance is recorded — and organizations
ratchet cohorts to `strict` as conformance holds. Policies resolve from the
org/enterprise catalog layer only; a project layer must not be able to weaken
them.

## Adoption

1. Add this catalog as a pinned source and `outfitter sync`.
2. Run an agent: `outfitter run sdlc-planner` — value with zero new
   machinery.
3. Point `sdlc-report` at your org with `governance/sdlc-baseline.yaml` as
   the baseline; treat its gaps as the backlog.
4. Copy a workflow into your org catalog under the same id and edit the
   data. Same-id layer precedence does the rest.

## Deliberately excluded

- **Execution overlays** (placement, models, secrets, capture profiles) —
  deployment state, never community-catalog content.
- **Control resources** — obligation semantics belong to the Outfitter
  governance RFC and are not settled enough to freeze here.
- **Baked graphs** — build artifacts, not authored resources.
