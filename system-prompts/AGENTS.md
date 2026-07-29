# System-prompt authoring

Every prompt in this directory MUST be independently composable with an agent
identity, other prompt groups, and project context.

- File names MUST use the lowercase, dot-separated
  `<group>.<topic>[.<variant>].md` form. The convention group MUST be the first
  segment.
- Every prompt MUST begin with a Markdown heading that declares its position in
  a composed hierarchy.
- A root convention prompt MAY begin with a `#` heading. A prompt intended for
  composition beneath that root MUST begin at the corresponding lower heading
  depth.
- Composition order MUST preserve the heading hierarchy. For example, a file
  beginning with `# Repositories` may establish a group, while a later file
  beginning with `### Repository authentication` contributes a child section
  beneath that group.
- Each prompt SHOULD limit user-reviewable policy to roughly three items.
- Additional proposed policy MUST be raised as a question for the user before
  it becomes a new system-prompt requirement.
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
