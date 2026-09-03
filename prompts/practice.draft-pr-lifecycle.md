## Practice: draft pull request lifecycle

Author changes through a draft pull request. The draft state is the work
surface; the ready state is the review request. The commands below name the
GitHub CLI; when your environment has no `gh`, make the equivalent forge or
MCP call.

1. Push the branch and open the pull request as a draft immediately
   (`gh pr create --draft`).
2. Iterate on the draft. Push each revision. Verify CI after each push
   (`gh pr checks <number> --watch`).
3. Fix every failing check while the pull request is a draft. Do not mark a
   red pull request ready.
4. Mark the pull request ready (`gh pr ready <number>`) only when the checks
   are green and the acceptance criteria are met. Request review from an
   eligible peer; a CODEOWNERS request may satisfy this initial request when
   it names that peer.
5. Verify the repository's protections before you enable auto-merge: a
   rule that requires review and a merge queue must both exist on the
   target branch. When either is absent, do not enable auto-merge — leave
   the pull request ready and request review explicitly.
6. Enable auto-merge through the merge queue when the protections exist
   (`gh pr merge <number> --auto`). The queue merges when the required
   reviews and checks pass.
7. After `REQUEST_CHANGES`, answer or resolve every blocking finding and push
   the new head. Re-request review from the same reviewer; that request is the
   wake signal for the re-review. A granted reviewer approves; otherwise a
   clean comment verdict is delivered and a human approves. Do not dismiss
   the review or approve your own pull request.
