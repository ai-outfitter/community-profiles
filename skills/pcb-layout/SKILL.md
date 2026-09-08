---
name: pcb-layout
description: Build and route a KiCad PCB from a reviewed standard netlist with deterministic pcbnew inputs, a bounded freerouting DSN/SES loop, all-severity DRC, warning ratchets, and reproducible renders.
---

# PCB layout

Convert an independently reviewed standard KiCad netlist into a reproducible
board. Derive the stackup, outline, materials, drill rules, impedance needs,
clearances, placement constraints, and other fabrication limits from the board
requirements. Do not substitute catalog defaults for missing requirements.

## Procedure

1. Make the pcbnew build declarative and idempotent. Pin its toolchain and input
   libraries. Create nets and footprints from the reviewed netlist, then apply
   the requirement-owned stackup, outline, holes, rules, placement, keep-outs,
   zones, and documentation.
2. Verify that every netlist part and pad is represented exactly once and that
   no undeclared electrical footprint or net appears on the board. Keep
   mechanical-only items explicitly classified.
3. Save the board, reload it with pcbnew, and only then fill zones. Validate the
   reloaded artifact rather than relying on transient in-memory state.
4. Run pre-route DRC at all severities. Resolve placement, courtyard, edge,
   stackup, and rule failures before routing.
5. Add only the deliberate pre-routes required by the electrical constraints.
   Export Specctra DSN, run freerouting with a time and attempt limit, and import
   the chosen SES result. Record each attempt and its residual unrouted nets.
   If the bounded loop does not converge, change placement or route the named
   residuals deliberately; do not relax rules or add layers without changing
   the approved requirements.
6. Restore required zones and deliberate routes, save and reload, refill, and
   run DRC at all severities. Errors and unconnected items must be zero. Compare
   warnings by stable identity against the approved warning baseline; reject
   new identities unless a cited review updates the baseline.
7. Check constraints that DRC does not prove: current paths, return paths,
   thermal paths, decoupling distance, sensitive-node isolation, connector and
   mounting access, test access, polarity marks, and legible fabrication and
   silkscreen data.
8. Generate top, bottom, copper, and 3D renders declared by the repository.
   Preserve the board, DSN/SES evidence when used, DRC reports, warning
   baseline, routing log, and renders for independent review.

## Handoff

The output is ready for layout review when it rebuilds from committed inputs,
the all-severity gates pass, and the evidence identifies every waiver. A clean
DRC is a floor; it does not establish electrical, thermal, mechanical, or
manufacturing fitness.
