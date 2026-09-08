# RFC: Resident hardware development workflows

- Status: Proposed
- Target: `ai-outfitter/community-profiles`
- Execution boundary: Outfitter resolves and exports the workflows; an execution
  engine runs them.

The terms MUST, MUST NOT, SHOULD, and SHOULD NOT are normative requirements.

## Summary

Add a family of small hardware-development workflows to the community catalog.
A resident hardware engineer coordinates typed issues, bounded execution jobs,
review, release, fabrication, and acceptance. Digital changes use the catalog's
existing engineering lifecycle: semantic branch, draft pull request, required
checks, independent review, adversarial review, and platform-controlled merge.

The parent workflow finalizes a compatible set of merged design changes as a
tagged hardware design release before fabrication. Fabrication verifies the
release by commit identity and artifact checksums. Physical work remains the
responsibility of a human or an `edge-runner`. Evidence from that work enters
Git through the same reviewed pull-request lifecycle as digital design work.

Execution environments describe capabilities rather than locations. An
interactive design runtime can be a Kubernetes workload, a virtual machine, or
a workstation. A workflow MUST NOT assume that an interactive application runs
on the resident agent's desktop.

## Motivation

Software-oriented engineering governance is useful for hardware: issues state
intent, pull requests expose the change, CI checks machine-readable artifacts,
and reviews challenge the author's assumptions. Hardware adds three boundaries
that the existing `software-factory` workflow does not express:

1. Several artifact classes, such as circuit boards and mechanical assemblies,
   MUST converge into one compatible configuration.
2. Fabrication spends money and creates a physical article from an exact design
   revision.
3. Receipt, assembly, and bench tests produce evidence that cannot be inferred
   from a successful build.

A resident deployment can coordinate work continuously, while expensive,
privileged, interactive, or review-isolated tasks run as bounded workloads with
purpose-built tools and permissions.

## Goals

- Preserve the existing issue, draft-PR, CI, adversarial-review, auto-merge,
  and release conventions.
- Represent PCB design, CAD design, assembly integration, visualization,
  fabrication, and acceptance as small composable child workflows.
- Allow a resident agent to dispatch bounded execution jobs.
- Keep interactive design applications independent of a particular desktop or
  hosting substrate.
- Require fabrication artifacts to come from a tagged release identified by
  commit and checksums. Human authorization separately covers cost, quantity,
  supplier, and substitutions.
- Record the exact digital configuration, toolchain, artifact identities and
  checksums, waivers, and acceptance-evidence references in Git history.
- Keep workflows and skills generic enough for the community catalog.

## Non-goals

- Execute workflows inside Outfitter.
- Define a Kubernetes workflow controller or a new job protocol.
- Give a resident pod direct access to printers, USB devices, instruments, or
  purchasing credentials.
- Standardize one CAD package, visualization engine, PCB fabricator, printer,
  forge, or release-note generator.
- Claim that simulation, rendering, or automated checks prove physical fitness.
- Replace component revision identifiers with repository semantic versions.

## Existing contracts

This RFC builds on these catalog contracts:

- `software-factory` establishes typed issue intake, implementation, draft pull
  request, required CI, adversarial review, and merge after approval.
- `adversarial-review` supplies an independent review before merge.
- The engineer's draft-PR practice enables auto-merge only when branch
  protections, required checks, and required reviews are effective.
- Outfitter workflow nodes declare ordering and outputs. Outfitter does not run
  nodes or record output values.
- Release Please currently converts Conventional Commits into a release pull
  request, changelog, tag, and published release for this catalog.

The proposed workflows MUST NOT weaken any of these contracts.

## Agents and skills

Add one runnable agent, `hardware-engineer`, which inherits `engineer`. It owns
coordination, artifact reconciliation, and evidence reporting. A distinct agent
is warranted when hardware work is a standing, forge-addressable resident
responsibility with a specialized skill and authority boundary. A consumer
without that boundary can add the skills to `engineer` instead. Operators decide
whether to run the agent continuously; the catalog agent can also run in bounded
or interactive environments.

Separate PCB, CAD, visualization, fabrication, and acceptance agents MUST NOT be
added initially. Those are capabilities of the hardware engineer and bounded
execution jobs, not standing organizational identities.

The initial skill set is:

- `pcb-schematic`
- `pcb-layout`
- `pcb-review`
- `pcb-release`
- the existing `replicad` CAD skill
- `visualization-validation`
- `hardware-acceptance`

The PCB skills may remain separate because they define different gates and
review contexts. The new skills SHOULD route to repository-native commands and
artifact conventions instead of imposing one project layout.

## Execution environments

Workflow resources use a small capability vocabulary. The execution engine maps
each capability to local processes, Kubernetes workloads, virtual machines, or
external systems.

| Environment | Required capability |
| --- | --- |
| `resident` | Long-lived intake, coordination, forge access, and workflow state |
| `design-job` | Bounded non-interactive design and validation tools |
| `review-job` | Fresh context, read-only inputs, and no author briefing |
| `interactive-design-runtime` | Interactive graphics session and required compute or accelerator access |
| `edge-runner` | Explicit access to a printer, instrument, fixture, or device under test |
| `human` | Purchasing, safety decisions, assembly, inspection, and other accountable physical actions |
| `platform` | Branch protections, merge queue, tag publication, and release automation |

`interactive-design-runtime` specifies capabilities without prescribing where
the display server or application runs. The capability may be implemented by a
workload or virtual machine accessed through remote desktop, or by a
workstation.

The resident coordinates jobs without bundling every job's tools into its
long-running image. Job images SHOULD be pinned by digest. Credentials SHOULD
be scoped to the operation and mounted only for its lifetime. They MUST NOT be
copied to the resident volume or committed as evidence. Durable design state
belongs in Git or an artifact store, not only on the resident volume.

## Common engineering lifecycle

Every workflow that changes a durable design or evidence record follows this
spine:

```text
receive typed issue
  -> implement and verify on a semantic branch
  -> open a draft pull request
  -> wait for required CI
  -> run adversarial pull-request review
  -> enable auto-merge
  -> let the platform merge after approval
```

The resident MUST NOT push to the default branch, force a merge, dismiss a
review, or reinterpret a failed check as acceptance. Enabling auto-merge does
not grant merge authority: the merge queue acts only after repository policy is
satisfied.

A child workflow's domain action specializes `implement and verify`; it does
not replace the surrounding governance. Artifact-specific domain review and
adversarial pull-request review are separate gates. Domain review checks the
artifact with specialized tools and a fresh context. Adversarial review checks
the proposed repository change after required CI. A workflow places domain
review where its artifact is ready to inspect.

The child definitions use `complete common pull-request lifecycle` as shorthand
for opening the draft pull request through platform-controlled merge in the
spine above.

## Workflow family

### `hardware-development`

The parent coordinates one hardware configuration from its tracking issue to an
accepted configuration.

```text
receive configuration issue
  -> freeze interface and acceptance contract
  -> dispatch pcb-design and cad-design
  -> assembly-integration
  -> visualization-validation
  -> hardware-release
  -> hardware-fabrication
  -> hardware-acceptance
  -> close configuration issue
```

PCB and CAD work may proceed concurrently after their shared interfaces are
frozen. The integration workflow reconciles their outputs before release.

Proposed outputs, shown as `output-name: type-label`:

- `configuration-issue: issue`
- `design-release: design-release`
- `release-commit: git-commit`
- `fabrication-record: fabrication-record`
- `accepted-configuration: accepted-configuration`

### `pcb-design`

```text
receive typed issue
  -> design and machine-verify schematic
  -> independent schematic review
  -> place, route, and machine-verify board
  -> independent layout review
  -> generate fabrication package
  -> complete common pull-request lifecycle
```

Proposed outputs, shown as `output-name: type-label`:

- `pull-request: pull-request`
- `merge-commit: git-commit`
- `pcb-design: pcb-design`
- `fabrication-package: fabrication-package`
- `review-evidence: review-evidence`

The fabrication package is reviewable output, not authorization to order it.

### `cad-design`

```text
receive typed issue
  -> build authoritative parts and assembly
  -> verify dimensions, interfaces, clearances, and assembly constraints
  -> export deterministic exchange and printable artifacts
  -> independent CAD review
  -> complete common pull-request lifecycle
```

Proposed outputs, shown as `output-name: type-label`:

- `pull-request: pull-request`
- `merge-commit: git-commit`
- `cad-design: cad-design`
- `exchange-model: exchange-model`
- `printable-package: printable-package`
- `review-evidence: review-evidence`

CAD source is authoritative. Meshes and other exchange artifacts are derived
and MUST identify their source commit.

### `assembly-integration`

```text
receive typed issue
  -> assemble PCB and CAD outputs
  -> check connectors, cables, mounts, envelopes, and service clearances
  -> run independent integration review
  -> record mismatches or approve the integrated assembly
  -> complete common pull-request lifecycle
```

Proposed outputs, shown as `output-name: type-label`:

- `pull-request: pull-request`
- `merge-commit: git-commit`
- `integrated-assembly: integrated-assembly`
- `integration-evidence: integration-evidence`

The integration workflow MUST NOT silently edit a child workflow's accepted
interface.

### `visualization-validation`

```text
receive typed issue
  -> prepare deterministic runtime assets
  -> import and place the assembly in an interactive design runtime
  -> capture scale, placement, and clearance evidence
  -> independently review the evidence and its limitations
  -> complete common pull-request lifecycle
```

Proposed outputs, shown as `output-name: type-label`:

- `pull-request: pull-request`
- `merge-commit: git-commit`
- `runtime-assets: runtime-assets`
- `visualization-evidence: visualization-evidence`

This workflow validates conversion, scale, and placement against its stated
inputs. Approximate host models and visual inspections are not engineering
measurements.

### `hardware-release`

This workflow converts a compatible set of merged component changes into the
tagged design revision that fabrication may consume after verifying its commit
identity and artifact checksums.

```text
collect merged child-workflow outputs
  -> freeze configuration manifest
  -> prepare or update release PR
  -> rebuild and verify release artifacts from the candidate commit
  -> wait for required CI
  -> independent release review
  -> adversarial release-PR review
  -> enable auto-merge
  -> let the platform merge after approval
  -> publish tag, release, artifacts, and checksums
```

Proposed outputs, shown as `output-name: type-label`:

- `release-pull-request: pull-request`
- `design-release: design-release`
- `release-commit: git-commit`
- `configuration-manifest: configuration-manifest`
- `release-artifacts: release-artifacts`

`prepare or update release PR` is tool-neutral. Release Please is the reference
implementation because it aggregates Conventional Commits and manages versions,
changelogs, release PRs, tags, and publication. A repository may use git-cliff
for changelog generation if another mechanism still owns the release PR,
version, tag, and publication contract.

### `hardware-fabrication`

```text
receive fabrication issue bound to one design release
  -> reconcile release artifacts and checksums
  -> obtain human authorization for cost, quantity, and supplier
  -> order or manufacture from the tagged release
  -> record supplier or print results in a draft PR
  -> CI, adversarial review, and platform merge
```

Proposed outputs, shown as `output-name: type-label`:

- `fabrication-issue: issue`
- `fabrication-record: fabrication-record`
- `evidence-pull-request: pull-request`
- `evidence-commit: git-commit`

Fabrication MUST NOT consume an open pull request, development branch, or
mutable default-branch head. The record identifies the release tag, release
commit, artifact checksums, quantities, substitutions, and responsible human.

### `hardware-acceptance`

```text
receive acceptance issue bound to fabricated articles
  -> inspect identity and as-received condition
  -> assemble and execute the declared physical acceptance suite
  -> reconcile logs, measurements, photographs, deviations, and serials
  -> independently review the evidence
  -> record the as-built baseline in a draft PR
  -> CI, adversarial review, and platform merge
```

Proposed outputs, shown as `output-name: type-label`:

- `acceptance-issue: issue`
- `acceptance-record: acceptance-record`
- `accepted-configuration: accepted-configuration`
- `evidence-pull-request: pull-request`
- `evidence-commit: git-commit`

A resident may guide the procedure and interpret supplied evidence. It MUST NOT
claim that it performed a physical observation.

## Release and revision model

The integrated repository release and physical component revisions answer
different questions and MUST both be preserved.

| Identifier | Meaning |
| --- | --- |
| Repository semantic version | Compatible integrated digital configuration |
| PCB revision | Fabricated electrical design revision |
| CAD part or assembly revision | Mechanical design revision |
| Firmware version | Software and protocol compatibility |
| Article or serial identifier | One manufactured physical instance |

Recommended integrated version policy:

- Major: an incompatible electrical, mechanical, network, or data interface.
- Minor: a backward-compatible capability addition or intentional component
  revision that preserves declared interfaces.
- Patch: a correction that preserves declared interfaces and capabilities.

Every change to a manufactured netlist, geometry, or production file requires a
new tagged release, even when its semantic bump is only a patch. Tags and
published artifacts MUST NOT be rewritten. Fabrication verifies the tag's
commit identity and artifact checksums before use.

The configuration manifest SHOULD include:

- release version and commit;
- component design revisions and source commits;
- requirements and acceptance-suite revisions;
- electrical, mechanical, network, and data interface versions;
- firmware and runtime-asset versions;
- tool and container-image versions or digests;
- artifact filenames and cryptographic checksums;
- accepted waivers and known limitations.

## Kubernetes and operator boundary

The upstream workflows declare actors, environments, dependencies, skills, and
outputs. They do not define how an execution engine creates a Kubernetes Job or
virtual machine.

A resident deployment is expected to:

1. Survey trusted channels for assigned issues and review requests.
2. Resolve the workflow and its pinned agent and skill closure.
3. Dispatch a bounded workload appropriate to the node's environment.
4. Record the workload identity, source commit, image digest, and output
   artifact references.
5. Continue the graph only after the declared output exists and the execution
   engine verifies its required external state.

Review jobs MUST receive a fresh context and read-only design inputs. Interactive
design runtimes may use remote display infrastructure, but their repository
write authority MUST remain no broader than the workflow node requires. Only an
explicitly designated edge runner or human may access hardware.

## Failure and retry semantics

- A failed CI or review node blocks merge.
- A failed domain review returns findings to the same semantic branch and
  tracking issue. If a draft PR already exists, attach the findings there.
- A failed integration check creates or reopens a component issue.
- A failed release build blocks the release PR.
- A failed fabrication attempt records what was consumed and creates a new
  fabrication attempt; it does not change the source release.
- A failed acceptance test records the failure against the article and design
  release. Design changes proceed through a new issue, PR, and release.
- Workflow retries MUST be idempotent or create a new explicitly identified
  attempt.

## Upstream implementation sequence

The implementation SHOULD land as independently reviewable pull requests. Read
the projected history from bottom to top:

```text
◇  next community-profiles release
│
│ ○  feat(workflows): compose resident hardware development and release
├─╯  PR 3
│ ○  feat(workflows): add hardware design and evidence workflows
├─╯  PR 2
│ ○  feat(hardware): add hardware engineer and reusable skills
├─╯  PR 1
●  main at RFC acceptance
```

PR 1 adds the reusable capability closure. PR 2 adds and validates the child
workflows. PR 3 adds the parent workflow, release composition, documentation,
and full-closure export tests. Release Please then publishes the catalog
release.

## Acceptance criteria

The RFC is implemented when:

1. Every proposed workflow validates in strict mode and exports
   deterministically twice.
2. `hardware-development` resolves the complete child-workflow, agent, skill,
   prompt, MCP, and artifact closure.
3. Every durable design and evidence change passes through an issue and reviewed
   pull request.
4. Every digital workflow includes required CI, independent domain review,
   adversarial review, and platform-controlled merge.
5. A release fixture proves that fabrication verifies a tagged release by
   commit identity and artifact checksums.
6. An execution fixture maps resident, job, interactive-runtime, edge, human,
   and platform nodes without assuming a workstation desktop.
7. A failed physical acceptance fixture cannot produce an
   `accepted-configuration` output.
8. Documentation distinguishes automated evidence, visual evidence, human
   observation, and physical acceptance.

## Open questions

1. Which execution engine owns the canonical mapping from workflow environment
   labels to Kubernetes Jobs and interactive runtimes?
2. Should large design artifacts live in forge release assets, an OCI registry,
   or a content-addressed object store by default?
3. Does the workflow contract need a first-class attempt identifier, or is an
   execution-engine record sufficient?
4. Should accepted physical configurations receive a separate signed
   attestation, or is the reviewed acceptance commit the initial contract?
