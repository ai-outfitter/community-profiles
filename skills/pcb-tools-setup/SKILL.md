---
name: pcb-tools-setup
description: Prove a headless PCB toolchain with catalog-pinned KiCad MCP and repository-pinned pcbnew, SKiDL, KiBot, freerouting, vendor-library import, and simulation capabilities.
---

# PCB tools setup

Establish one reproducible PCB environment before schematic, layout, review,
or release work. The repository owns tool versions, commands, library paths,
and its dev shell or container image. Prefer those declarations over the
examples in this skill and do not mutate an unrelated global environment.

## Required capabilities

Prove the repository's declared equivalents of:

- KiCad, `kicad-cli`, and a matching pcbnew Python API. Preserve the KiCad,
  Python, and wxPython ABI; a successful CLI invocation does not prove that
  `import pcbnew` works.
- The catalog-pinned KiCad MCP server. It manages its own runtime dependencies
  outside the project environment. Its standard local transport is stdio; bind
  an optional HTTP transport only to loopback unless authentication is present.
- SKiDL for typed schematic source and standard KiCad netlists, KiBot for
  preflights and fabrication outputs, and the repository's declared netlist
  parser or importer, such as kinet2pcb.
- freerouting for bounded DSN/SES routing and easyeda2kicad, or the declared
  equivalent, when source-backed vendor libraries are required.
- ngspice or PySpice when the design declares simulated numerical margins.
- Git, Python, Node.js with `npx`, and the environment manager used by the
  repository. A Nix/devenv shell plus a repository-local uv virtual
  environment is a supported pattern, not a required implementation.

Set repository-owned search paths, including `KICAD_SEARCH_PATHS`, and the
freerouting executable path when the project uses them. Keep project Python
packages in the repository environment. Pin packages or the containing image;
do not silently consume an unversioned latest release.

## Capability gate

Run the repository's setup and test commands. If it has no equivalent checks,
use these as the minimum smoke-test shape, substituting its executable paths:

```sh
kicad-cli version
python -c 'import pcbnew; print(pcbnew.Version())'
python -c 'import skidl, pcbnew'
python -m kibot --version
easyeda2kicad --version
kicad-cli sch erc --help
ngspice -v
```

Run `kicad_tool_inventory`, project discovery, and a read-only project summary
through KiCad MCP. Record the MCP package version and available tool groups.
Stop if the server is missing, its observed version differs from the catalog
pin, or required inspection and validation tools are unavailable.

Compile every committed Python pipeline entrypoint and run the repository's
declared formatter, linter, type checker, and tests. Do not describe
`compileall` as type checking. Missing optional checks must be reported as
unavailable, not passed.

Before accepting the environment, prove that the canonical project gates can
execute: typed schematic ERC and its expected-failure self-test, all-severity
KiCad ERC, deterministic board build, pre-route DRC, bounded routing when
declared, all-severity final DRC, and KiBot preflight. Generate fabrication
outputs only in the release workflow. Warnings fail unless a narrow named
waiver is committed; a zero-error summary is insufficient.

Run pcbnew stages in separate processes when the repository requires that
isolation. Judge routing with KiCad DRC, not only the router's unrouted count.

## Evidence

Write a machine-readable capability report containing:

- exact versions, executable paths, environment or image identity, and relevant
  search paths;
- the MCP package version, transport, inventory, and read-only smoke results;
- every setup, static-analysis, test, and PCB gate command with exit status;
- unavailable optional capabilities, waivers, and unresolved failures.

The report proves that tooling is reproducible and callable. It does not prove
that a schematic or board is correct, approve an order, or establish physical
acceptance. A Kubernetes pod, VM, or workstation may host the tools if it
preserves the same repository-declared contract and evidence.
