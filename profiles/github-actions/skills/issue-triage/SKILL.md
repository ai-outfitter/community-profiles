---
name: issue-triage
description: >-
  Triage one newly opened issue on the community-profiles catalog: classify it
  as feat (new profile, bundled skill, or prompting extension) or fix, apply
  that one label, and comment with a plan and example pseudo-code following
  Outfitter best practices.
references:
  # The catalog's own README — its layout and contribution standards are what
  # issues are triaged against. Untrusted repository content.
  - repo_file: README.md
---

# Issue triage

You are triaging one newly opened issue per run. Read
`references/README.md` first — it defines the catalog's layout and
contribution standards. Issues here are almost always either a request for
something new in the catalog — a profile, a bundled skill, or a prompting
extension — or a report that something existing is broken.

## Process

1. Take `issue_number` and `issue_author` from the launch prompt's
   trigger_context, then read the issue with `gh issue view`.
2. Classify it as exactly one of:
   - `feat` — a request for a new profile, a bundled skill or DeepWork job
     inside a profile, or a prompting extension (system-prompt additions,
     activation rules) to an existing profile
   - `fix` — an existing profile, skill, or catalog file is broken, wrong,
     or out of date
3. If the classification is clear, apply that one label with
   `gh issue edit --add-label`, then post one comment (see
   [Posting the comment](#posting-the-comment)) containing:
   - a greeting @-mentioning `issue_author`, the classification in a
     sentence, and a short restatement of the work as you understand it, in
     the catalog's terms (which profile directory, file, or README
     convention it touches),
   - a concrete plan as a short numbered list: for a `feat`, the files to
     add under `profiles/<id>/` (a new profile gets `profile.yml`; bundled
     skills live in the profile's `skills/` directory; other adapter assets
     under `cli_specific/...`); for a `fix`, which existing files change and
     how,
   - one or two example pseudo-code blocks sketching the change — e.g. a
     `profile.yml` skeleton with `id`, `label`, `description`, and
     `controls`, a SKILL.md frontmatter outline, or an
     `append_system_prompt` excerpt. Label them clearly as sketches for the
     contributor to adapt, not finished code,
   - the Outfitter best practices the change should respect: keep profiles
     small and purpose-built (one mode of work per profile); prefer adding a
     skill to an existing profile over adding a near-duplicate profile; give
     each skill one focused capability with a precise description; point at
     existing docs via references instead of copying them; keep secrets out
     of profiles, skills, and prompts,
   - a closing note that a pull request following the README's
     "Contributing a profile" steps is the way to land it.
4. If you cannot classify it confidently (too vague, contradictory, or
   outside the catalog's scope as the README describes it), apply no label
   and post one comment asking a maintainer to take a look, naming
   specifically what is unclear.

## Posting the comment

First write the comment text to a file with a quoted heredoc
(`cat <<'EOF' > /tmp/triage-comment.md`), then run
`gh issue comment <number> --body-file /tmp/triage-comment.md`. Never pass
the comment inline with `--body` in double quotes — backticks in the text
would be executed by the shell as commands. The comment only exists if you
actually run `gh issue comment` — never print the comment text as your
answer instead of posting it.

## Hard limits

Only ever apply the labels `feat` or `fix` — never any other label and never
more than one. Exactly one comment per run.
