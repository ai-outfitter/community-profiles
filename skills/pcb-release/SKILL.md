---
name: pcb-release
description: Rebuild and gate an exact PCB commit, then use repository-declared KiBot or equivalent outputs to create a checksummed fabrication package without authorizing manufacture.
---

# PCB release

Create a reproducible fabrication package from the exact reviewed commit.
KiBot is the reference orchestrator, but the contract is tool-neutral: the
repository declares its preflights, generators, output names, and any optional
manufacturer adapter.

## Procedure

1. Start from a clean checkout of the candidate commit in the pinned design-job
   environment. Record the commit and tool or container image versions before
   generating artifacts.
2. Rebuild the canonical named-pin SKiDL source, standard KiCad netlist, and
   pcbnew board. Rerun the schematic gates, fault test, numerical checks,
   baseline policy, all-severity DRC, and warning-identity ratchet. Verify that
   both recorded domain review verdicts are `release-ready`, name their source
   commits, and contain checksums matching the rebuilt reviewed inputs. Stop on
   any regression, `not-ready` verdict, checksum mismatch, or missing review
   evidence.
3. Run the repository's KiBot configuration or equivalent release command.
   Generate the repository-declared outputs, which normally include Gerbers,
   drill data, BOM, pick-and-place data, and board renders. Do not claim KiBot
   produced a BOM, render, or other artifact unless the active configuration
   actually declares it; a repository helper may generate an output that its
   schematic representation cannot supply.
4. Check the package for a closed outline, declared stackup and layers,
   consistent units and origins, complete drill data, complete populated-part
   metadata, BOM-to-placement agreement, and readable renders. Apply a
   manufacturer-specific naming, rotation, panel, or archive adapter only when
   the repository explicitly selects it.
5. Write a machine-readable manifest containing the source commit; tool and
   image versions; requirements and approved-baseline identities; every output
   filename, size, and cryptographic checksum; resolved warnings and waivers;
   and the successful gate and review evidence identifiers or paths.
6. Re-run the package command when the repository requires reproducibility and
   compare the declared deterministic outputs. Explain any format-level
   nondeterminism rather than silently accepting checksum drift.

## Boundary

The fabrication package is an inspectable digital release candidate. It does
not authorize an order, approve cost or substitutions, operate fabrication
equipment, prove manufacturability, or establish physical acceptance.
