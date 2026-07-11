# Outfitter community profiles

Community-contributed profile catalog for [Outfitter](https://github.com/ai-outfitter/outfitter). Profiles here are shared by the community, reviewed for structure but not curated like the [default profiles](https://github.com/ai-outfitter/default-profiles) — read a profile before you run it.

## Using this catalog

Add the catalog as a profile source and sync:

```yaml
# ~/.outfitter/settings.yml
profile_sources:
  - github: ai-outfitter/community-profiles
    ref: <tag-or-commit>
```

```sh
outfitter sync
outfitter run --profile <id>
```

Pin `ref` to a tag or commit — an unpinned source runs whatever the catalog publishes next.

## Contributing a profile

1. Copy the layout of an existing profile: `profiles/<id>/profile.yml` with `id`, `label`, `description`, and `controls`.
2. Keep profiles small and purpose-built — one mode of work per profile, not an everything setup.
3. Bundled skills, prompts, or DeepWork jobs live inside the profile directory (`profiles/<id>/cli_specific/...`).
4. Open a pull request. The description should say what the profile is for and which agent adapters it targets (Pi, Claude Code).

Prefer opening an issue first: newly opened issues are triaged automatically by the [`github-actions` profile](profiles/github-actions/profile.yml)'s bundled [issue-triage skill](profiles/github-actions/skills/issue-triage/SKILL.md) (running on this repo via [`ai-outfitter/actions`](https://github.com/ai-outfitter/actions), see [.github/workflows/issue-triage.yml](.github/workflows/issue-triage.yml)). The agent labels the issue `feat` (new profile, bundled skill, or prompting extension) or `fix`, and comments with a suggested plan and example sketches following Outfitter best practices.

## Layout

```text
profiles/       one directory per profile
settings.yml    catalog metadata (profile source root)
```
