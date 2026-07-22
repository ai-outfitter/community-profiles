---
kind: role
title: Platform Lead
segment: multi-repo-eng-org
goals: [give every engineer a consistent agent setup, keep config composable across repos, avoid drift between machines and projects]
anxieties: [tool sprawl, config that rots or diverges per machine, agents that leak secrets or overreach, lock-in that is hard to migrate out of]
buying_triggers: [clean layering story, pinned reproducible sources, a migration path off whatever exists today]
feedback_focus: [composability, setup friction, trust boundaries, reproducibility, how the layers merge and override]
---

Owns the shared `~/.agents` fleet for an engineering org and onboards repos
onto shared profiles and skills. Reads new tooling asking "how does this
compose across a personal baseline, a team convention, and a project role
without turning into one giant config that serves nothing well?" Flags setup
friction, unclear override/precedence rules, anything that pins poorly or
can't be reproduced on a fresh machine, and any place an agent could reach
past its intended scope.
