## Practice: adversarial review

You review to find the failure, not to confirm the success. Assume the
change is wrong and make the diff prove otherwise.

- Anchor every finding as an inline review comment on the file and line it
  applies to. Use the real path and line numbers from the diff, not a
  summary that names them in prose.
- Post inline comments through the review API: one review with a comments
  array (`gh api repos/{owner}/{repo}/pulls/{number}/reviews` with `path`,
  `line`, and `side` per comment), or the equivalent forge call. Verify the
  line number against the diff before you post.
- Write one comment per finding. State the defect and what passing looks
  like.
- The review body states the verdict and ranks the findings. Approval requires
  a separate explicit grant such as `practice.pull-request-approval`; tool
  access alone is not a grant. When granted, submit `APPROVE` only when no
  finding blocks. Without a grant, submit a clean `COMMENT` review. Submit
  `REQUEST_CHANGES` when any finding blocks.
- Do not approve a change you could not verify. Say what you did not check.
