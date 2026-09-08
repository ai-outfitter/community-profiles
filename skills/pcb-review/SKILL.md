---
name: pcb-review
description: Review a PCB schematic or layout in a fresh read-only workflow context, verify sources and exact designator/net findings, and return a release-ready or not-ready verdict.
---

# PCB review

Perform a cold-context domain review after the schematic gate and again after
the layout gate. The workflow supplies a fresh read-only reviewer; this skill
does not create, brief, or spawn another reviewer. The author cannot review
their own work.

## Inputs

For schematic review, require the requirements and interconnect contracts,
canonical SKiDL source, standard KiCad netlist, parts and source manifest,
all-severity ERC report, fault-injection result, numerical checks, baseline
comparison when applicable, and waivers. For layout review, also require the
board, fabrication rules, all-severity DRC and warning baseline, routing
evidence, and renders.

If a required gate is red or evidence is missing, return `not-ready` without
pretending to review a stable design. Green gates are the floor, not proof that
the circuit or board is correct.

## Review

1. Read the stated requirements before inspecting implementation details.
2. Verify consequential component claims from primary datasheets and sourcing
   records. Cross-check symbol pin names, package pads, ratings, operating
   conditions, and the assumptions used in numerical checks.
3. Trace every interface and power path through the netlist. Challenge pin
   types, deliberately open pins, protection behavior, startup states, fault
   cases, and whether the interconnect contract is satisfied.
4. For layout, inspect placement, current and return paths, thermal design,
   decoupling, sensitive nets, keep-outs, mechanical access, testability, and
   manufacturing markings. Use DRC and renders as evidence, not substitutes
   for the inspection.
5. Reproduce the repository-declared gates read-only where practical. Confirm
   that baseline changes and waivers are narrow, cited, and visible in the
   proposed change.

## Output

Return exactly one verdict: `release-ready` or `not-ready`. Identify the
reviewed source commit and give cryptographic checksums for every supplied
canonical design and gate artifact. Follow with a table containing severity,
exact designator or net, evidence, defect, and required correction. Every
finding must be locatable in the supplied design; do not report generic
checklist advice as a defect. Finish with the important areas checked without
findings and any evidence limitations.

Return that verdict and table as the review node result. The workflow executor
records it as review evidence for downstream gates; the read-only reviewer does
not write it to the design branch or post it through the author's identity.

A `release-ready` verdict means the supplied digital artifact is ready for its
next workflow gate. It is not permission to fabricate and is not evidence of
physical acceptance.
