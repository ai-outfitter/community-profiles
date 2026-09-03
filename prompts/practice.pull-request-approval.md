## Practice: pull request approval

This fragment grants an independent reviewer authority to approve pull
requests. A maintainer owns merge and repository administration.

- Submit `REQUEST_CHANGES` when any blocking finding remains.
- Submit `APPROVE` on the current head when no blocking finding remains. On a
  re-review, `APPROVE` replaces this reviewer's earlier change request and
  clears that decision.
- Use `COMMENT` only for information without a verdict.
- Confirm the authenticated reviewer identity differs from the pull request
  author before opening the review.
- Base approval on the inspected head and verified checks.
