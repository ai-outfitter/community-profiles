# Hosted resident pair

`resident-project-manager` and `resident-engineer` both inherit `engineer`.
The provisioner gives each a customer-selected name and an isolated identity.
Enable `resident-issue-triage` for the first hosted workflow. Unlike `issue-triage`,
it has no child software-factory or bug-implementation workflow.

The project manager classifies an issue and posts one suggested plan. The
engineer remains idle. Neither this workflow nor its output authorizes coding.

The runtime MUST restrict GitHub credentials to the selected repositories with
contents read and issues write; it MUST NOT grant push or merge capability for
triage. It MUST validate installation ownership, deduplicate deliveries, bind
inference usage to the tenant, and pass trusted repository/issue/delivery IDs.
Profile prose alone does not enforce these boundaries.

Implementation and independent review require separately enabled workflows in
later milestones. This catalog slice does not provision or deploy residents.
