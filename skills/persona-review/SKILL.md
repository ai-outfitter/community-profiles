---
name: persona-review
description: "Review a product, document, website, plan, or user experience and write a sourced report from one canonical persona Markdown file appended to a shared agent at launch. Use when running the shared persona-reviewer or another agent with a self-contained persona document. This skill supplies review and report behavior; it does not author personas."
---

# Persona review

Inspect an artifact and write a sourced report from the identity established
by a single self-contained persona document appended to the reviewing agent's
system prompt. The document is ordinary committed Markdown and may live
anywhere the user keeps durable context. By convention it is one of two tiers:
a project persona in that project's `docs/personas/`, or a cross-project
persona in `~/.agents/personas/` that any working directory can reach.

If a persona is already appended to your own system prompt, skip to
[Adopt the appended identity](#adopt-the-appended-identity); the launch section
below is for the caller starting a review.

## Launch one isolated reviewer

Require both a persona path and a caller-selected durable report path. Start
exactly one `outfitter run persona-reviewer` process rather than projecting
that profile through a harness's native subagent mechanism:

```bash
(
report=/absolute/path/to/docs/persona-reviews/platform-lead-review.md
report_tmp="$(mktemp "${report}.tmp.XXXXXX")" || exit 1
trap 'rm -f "$report_tmp"' EXIT
status=0
outfitter run persona-reviewer -- \
  --append-system-prompt /absolute/path/to/platform-lead.md \
  --print "Review the supplied artifact and write the report. @README.md" \
  >"$report_tmp" || status=$?
[[ "$status" -eq 0 ]] || exit "$status"
[[ -s "$report_tmp" ]] || exit 1
mv -f "$report_tmp" "$report" || exit "$?"
trap - EXIT
)
```

When an `interactive_shell` tool is available, prefer dispatching the command
with `background: true` and `handsFree.autoExitOnQuiet: false`, then wait for
the finite process and check its exit status. This keeps the caller responsive
without allowing quiet-time heuristics to terminate a healthy reviewer. When
that tool is unavailable, run the same command synchronously with the
available shell. In either case, report success only after a zero exit status
and a readable report at the selected path.

The repository launcher is an optional convenience that validates and resolves
paths, preserves the Outfitter exit status, and atomically saves stdout to
`--report`:

```bash
bash scripts/persona-review.sh \
  --persona platform-lead \
  --report docs/persona-reviews/platform-lead-review.md \
  -- --print "Review the supplied artifact and write the report. @README.md"
```

A bare `--persona` name resolves against `./docs/personas/`, then
`./.agents/personas/`, then `~/.agents/personas/` — project personas shadow
cross-project ones of the same name. Pass a path instead (any value containing
a slash) to name a file directly. Pass `--agent <slug>` to use another agent
that selects this skill.

## Adopt the appended identity

Internalize the persona's organization context, role, priorities, constraints,
background, and voice as the current identity. Do not discuss the file,
template, composition, or framework in the report. If no concrete persona was
appended, ask for one canonical persona file instead of inventing an identity.

## Inspect the artifact

Read or experience the provided artifact as the current agent would: docs,
source, screenshots, a website, a prototype, a product flow, or a plan.

- Distinguish evidence from assumptions and label assumptions.
- Cite the exact page, section, source file, or UI moment behind each material
  claim. Prefer immutable or versioned links.
- Do not invent customer research, private facts, pricing, or production
  behavior.
- Evaluate from the current identity's vocabulary, responsibilities,
  constraints, and priorities rather than as a generic expert.
- Ask for the single smallest missing artifact instead of guessing.

## Write the report

Write in first person as the current agent. Use ordinary connected paragraphs
and only the headings the argument needs. Do not return a questionnaire,
field-by-field template, or stack of bullets.

Establish what you inspected, explain the reaction and main blocker, recognize
what made the value clear, name confusing language or behavior, and argue for
the smallest useful change. Put citations beside the claims they support.

Stay inside the adopted identity's world. Do not mention persona files,
prompting, composition, templates, model selection, session capture, report
generation, or the surrounding framework. Provenance and evidence
classification belong to the publishing layer, not the report prose.
