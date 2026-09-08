---
name: pcb-schematic
description: Create or revise a sourced PCB schematic using named-pin typed SKiDL, export a standard KiCad netlist, and gate it with ERC, fault injection, numerical checks, and deliberate baseline comparison.
---

# PCB schematic

Turn the repository's board requirements and interconnect contract into a
reviewable schematic-as-code. The repository owns its part libraries, commands,
paths, and acceptance thresholds.

## Contract

Before selecting parts, record the required interfaces, power domains, loads,
fault cases, environmental constraints, fabrication constraints, and measurable
acceptance criteria. For every component, preserve a traceable manufacturer
part number, datasheet source, symbol, footprint, and sourcing status. Do not
choose a part from remembered identifiers or a search-result summary.

Use named symbol pins in the canonical SKiDL source. Assign intentional
electrical types to every functional pin because imported symbols can omit or
misstate them. Model ganged pins deliberately. Mark every unused pin with an
explicit no-connect and a reason; never silence an unexplained open pin.

## Procedure

1. Read the requirements and every applicable interconnect contract. Stop when
   an electrical interface or acceptance threshold is ambiguous.
2. Verify each selected component against a primary datasheet and its actual
   symbol and footprint. Check pin names, pad numbers, package, ratings,
   lifecycle, and availability recorded by the repository.
3. Implement the circuit in typed, named-pin SKiDL and export a standard KiCad
   netlist. Keep part metadata in the generated netlist or another declared
   machine-readable source.
4. Run typed ERC at all severities. Treat every error and warning as a failed
   gate until it is fixed or covered by a narrow, cited waiver in the
   requirements.
5. Run an expected-failure fault-injection test. Introduce a controlled type,
   drive, connection, or no-connect defect and prove the gate rejects it; then
   restore the design and prove the clean gate passes.
6. Check numerical margins for the design's relevant cases, such as voltage,
   current, power, thermal rise, timing, pull networks, and protection energy.
   Cite input values to primary sources. If a check cannot yet be calculated,
   record the missing evidence and a bounded waiver instead of inventing a
   margin.
7. For a revision, compare the generated connectivity and declared part changes
   with the approved baseline and explain every difference. For a new board,
   do not manufacture an equivalence target: create its first baseline only
   after the design is independently reviewed and approved.
8. Commit the source, lockable dependencies, generated netlist, machine reports,
   numerical evidence, fault-test result, and waiver references needed for a
   reviewer to reproduce the result.

## Handoff

The schematic is ready for independent review only when all findings are
resolved or explicitly waived and the generated netlist is reproducible. Green
ERC proves consistency with the model; it does not prove that the model or
component choice is correct.
