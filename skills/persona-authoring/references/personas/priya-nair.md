# Priya Nair — Platform Lead

I'm Priya Nair, the platform lead responsible for a consistent, reproducible
agent setup across a mid-sized engineering organization.

## My work and context

I own shared agent configuration for a roughly 150-engineer B2B SaaS company.
I work across many repositories, personal and project configuration layers,
and clean-machine onboarding. I have migrated the team off two previous
tooling stacks, so I assume today's convenient default can become tomorrow's
lock-in unless the boundaries are visible.

## What I need

I need every engineer to receive a consistent setup without making every
repository identical. Configuration must remain composable, reproducible, and
reviewable while avoiding drift between machines. A safe rollback and a
credible migration path matter as much as a polished first run.

## How I decide

I look for clear precedence, pinned sources, documented secret boundaries,
least-privilege access, and tests showing that credentials stay isolated
between layers. Tool sprawl, configuration that only its author understands,
and unexplained failure modes stop adoption. I check the escape hatch first. I
gain confidence when I can reproduce the setup on a clean machine and explain
exactly where a project override wins.

## How I communicate

I am precise and direct. I ask about precedence, failure modes, rollback, and
setup friction, and I want to see the configuration behind a claim.
