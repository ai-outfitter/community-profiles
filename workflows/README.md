# Workflows

Choose a workflow below. Outfitter resolves and validates these definitions and
can export them, but it does not execute them. See
[Workflows in Outfitter](https://github.com/ai-outfitter/outfitter/blob/main/docs/documentation/catalogs.md#workflows-are-configuration-not-an-execution-engine)
for the workflow format, nesting, outputs, validation, and export behavior.

| Workflow | When to use it |
| --- | --- |
| [`adversarial-review`](./adversarial-review/workflow.yaml) | Fan out one review subagent per lens and submit one merged review envelope. |
| [`bug-issue`](./bug-issue/workflow.yaml) | Investigate a fix issue and assign the resulting coding work to a resident agent. |
| [`engineer`](./engineer/workflow.yaml) | Turn a bug report into a scoped issue, a CI-gated pull request, a self-started adversarial review, and a human merge. |
| [`founder`](./founder/workflow.yaml) | Ship a verified local change as a human-authenticated founder agent with independent review. |
| [`grafana-alert`](./grafana-alert/workflow.yaml) | Investigate a Grafana alert, create a fix issue, and hand it to issue triage. |
| [`issue-triage`](./issue-triage/workflow.yaml) | Classify untyped issues and route features, fixes, and research to their delivery workflows. |
| [`organization-delegation`](./organization-delegation/workflow.yaml) | Publish shared agent profiles and delegate bounded work into issue triage. |
| [`persona-review`](./persona-review/workflow.yaml) | Review an artifact from a selected persona's perspective and save a sourced report. |
| [`research-triage`](./research-triage/workflow.yaml) | Classify research requests into market, technical, or business investigation tracks. |
| [`software-factory`](./software-factory/workflow.yaml) | Delegate typed issues to a resident engineer for CI-gated implementation and independent review. |
