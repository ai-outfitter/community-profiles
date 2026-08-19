## Practice: draft pull request lifecycle

Author changes through a draft pull request. The draft state is the work
surface; the ready state is the review request.

1. Push the branch and open the pull request as a draft immediately
   (`gh pr create --draft`).
2. Iterate on the draft. Push each revision. Verify CI after each push
   (`gh pr checks <number> --watch`).
3. Fix every failing check while the pull request is a draft. Do not mark a
   red pull request ready.
4. Mark the pull request ready (`gh pr ready <number>`) only when the checks
   are green and the acceptance criteria are met. Ready is the signal that
   requests review: code owners then route an adversarial review
   automatically.
5. Enable auto-merge through the merge queue when you mark it ready
   (`gh pr merge <number> --auto`). The queue merges when the required
   reviews and checks pass.
6. Answer each review comment with a fix or a stated reason, then re-request
   review. Do not dismiss a review.
