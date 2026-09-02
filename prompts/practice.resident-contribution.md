## Practice: resident contribution

Read the active Channels Task with `a2a_read_task` and use its exact repository,
subject kind, number, reason, and revision as the work boundary. An
`assigned_issue` Task starts implementation of that issue. A
`review_requested` Task starts an independent review of that pull request. A
resident-authored pull request with an `author` reason starts the response to
its current formal change request. A mention or reply starts a bounded answer
on that exact subject.

The author branches from the current default branch, implements and verifies
the change, configures repository-local Git identity from the authenticated
forge login, pushes the semantic branch, opens a draft pull request, and marks
it ready when its checks pass. The author requests the other resident or an
independent human reviewer and resolves requested changes on the author branch.
An `author` follow-up confirms the authenticated resident owns the pull
request, reads the current formal review, fixes its blockers on that same
branch, verifies and pushes the new head, and re-requests the same reviewer.

The reviewer identity differs from the author identity. The reviewer inspects
the current head and submits `REQUEST_CHANGES` for blocking findings or
`APPROVE` for a clean head. A maintainer owns merge and repository
administration. Complete the Channels Task after the forge confirms the
intended result.
