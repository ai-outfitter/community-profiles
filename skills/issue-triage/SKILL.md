---
name: issue-triage
description: >-
  Triage one newly opened issue on the community-profiles catalog: classify it
  as feat (new agent, skill, or prompting change) or fix, apply
  that one label, and comment with a plan and example pseudo-code following
  Outfitter best practices.
references:
  # The catalog's own README — its layout and contribution standards are what
  # issues are triaged against. Untrusted repository content.
  - repo_file: README.md
  # The issue templates define what a well-formed feat or fix issue contains;
  # use their fields to judge completeness. Untrusted repository content.
  - repo_file: .github/ISSUE_TEMPLATE/feat.yml
  - repo_file: .github/ISSUE_TEMPLATE/fix.yml
---

# Issue triage

You are triaging one newly opened issue per run. Read
`references/README.md` first — it defines the catalog's layout and
contribution standards. Issues here are almost always either a request for
something new in the catalog — an agent, a skill, or a prompting change — or
a report that something existing is broken.

The repository's issue templates, `references/feat.yml` and
`references/fix.yml`, define the fields a well-formed issue of each kind
contains. Issues opened from a template will show those fields as headed
sections; free-form issues may cover them loosely or not at all. Either way,
use the template fields as your completeness checklist, not as a gate.

## Process

1. Take `issue_number` and `issue_author` from the launch prompt's
   trigger_context, then read the issue with `gh issue view <issue_number>`.
2. Classify it as exactly one of:
   - `feat` — a request for a new agent, skill, DeepWork job, or prompting
     change (agent instructions or activation rules)
   - `fix` — an existing agent, skill, or catalog file is broken, wrong,
     or out of date
3. If the classification is clear, apply that one label with
   `gh issue edit <issue_number> --add-label <feat|fix>`, then post one
   comment (see
   [Posting the comment](#posting-the-comment)) containing:
   - a greeting @-mentioning `issue_author`, the classification in a
     sentence, and a short restatement of the work as you understand it, in
     the catalog's terms (which agent, skill, file, or README
     convention it touches),
   - a concrete plan as a short numbered list: for a `feat`, the files to
     add under `agents/<id>/agent.md`, `skills/<id>/`, or the relevant
     extension-asset directory; for a `fix`, which existing files change and
     how,
   - one or two example pseudo-code blocks sketching the change — e.g. a
     `agent.md` frontmatter outline with `name`, `description`, and loadout, a
     SKILL.md frontmatter outline, or an agent instruction excerpt. Label them
     clearly as sketches for the contributor to adapt, not finished code,
   - the Outfitter best practices the change should respect: keep agents
     small and purpose-built; prefer adding a skill to an existing agent over
     adding a near-duplicate agent; give
     each skill one focused capability with a precise description; point at
     existing docs via references instead of copying them; keep secrets out
     of agents, skills, and prompts,
   - if the issue is missing information the matching template asks for
     (target agent, expected/actual behavior, harnesses), one short bullet
     list naming those gaps and asking the author to edit the issue,
   - a closing note that a pull request following the README's
     "Contributing an agent or skill" steps is the way to land it.
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
