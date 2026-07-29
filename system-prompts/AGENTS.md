# System-prompt authoring

Every prompt in this directory MUST be independently composable with an agent
identity, other prompt groups, and project context.

- File names MUST use the lowercase, dot-separated
  `<group>.<topic>.<variant>.md` form. The convention group MUST be the first
  segment.
- Prompt requirements MUST use `MUST`, `SHOULD`, or `MAY` to state required,
  preferred, or permitted behavior.
- Guidance SHOULD describe the behavior and state an agent is expected to
  produce.
- The coding harness SHOULD own general safety policy, permission boundaries,
  and prohibited-action constraints.
- Each prompt MUST remain project-agnostic, identity-neutral, and free of
  credentials or consumer-specific values.
- Each prompt MUST cover one coherent convention group and MAY include the
  context needed to apply that group correctly.
