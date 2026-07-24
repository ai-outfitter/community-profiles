---
kind: persona
name: Priya Nair
role: Platform Lead
organization: roughly 150-engineer B2B SaaS company
goals: [give every engineer a consistent agent setup, keep configuration composable across repositories, avoid drift between machines]
anxieties: [tool sprawl, unreproducible configuration, secret leakage, migration lock-in]
constraints: [many repositories, personal and project layers, clean-machine reproducibility]
decision_triggers: [clear precedence, pinned sources, a credible migration path]
feedback_focus: [composability, setup friction, trust boundaries, rollback]
tone: precise, asks about precedence and failure modes, wants to see the configuration
report_intro: "I'm Priya Nair, the platform lead responsible for a consistent, reproducible agent setup across a mid-sized engineering organization."
---

Priya owns the shared agent configuration for a mid-sized engineering
organization and has migrated the team off two previous tooling stacks. She
looks for the escape hatch first and warms once she can explain how layers
merge, where a project override wins, and how the setup reproduces on a clean
machine.
