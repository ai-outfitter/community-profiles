#!/usr/bin/env bash
# persona-review.test.sh — checks for the persona-review skill.
#
# Offline (default): persona/template shape, script syntax, arg-vector,
# exit codes, and catalog resolution via OUTFITTER_BIN (default: outfitter-dev).
# Live smoke (PERSONA_REVIEW_LIVE=1): one real `run reviewer` review that must
# emit the fixed output shape — needs a harness + a model/login.
#
# Usage:
#   bash persona-review.test.sh
#   PERSONA_REVIEW_LIVE=1 OUTFITTER_BIN=outfitter-dev bash persona-review.test.sh
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$skill_dir/../../../.." && pwd)"
outfitter_bin="${OUTFITTER_BIN:-outfitter-dev}"
cd "$skill_dir"

pass=0
fail=0
ok() {
  printf '  ok   %s\n' "$1"
  pass=$((pass + 1))
}
no() {
  printf '  FAIL %s\n' "$1"
  fail=$((fail + 1))
}
# Assert a file contains every given `^key:` frontmatter line.
has_keys() {
  local file="$1" missing="" key
  shift
  for key in "$@"; do
    grep -Eq "^${key}:" "$file" || missing="$missing $key"
  done
  [[ -z "$missing" ]] || {
    echo "    missing in $file:$missing" >&2
    return 1
  }
}
# Exit code of a command, without tripping the test on failure.
exit_code() {
  "$@" >/dev/null 2>&1
  printf '%s' "$?"
}

role_keys=(kind title segment goals anxieties buying_triggers feedback_focus)
person_keys=(kind name roles born location household_income education employer hobbies skills tone)

echo "persona-review checks (bin: $outfitter_bin)"

# 1. Shape — reference docs + templates carry the required keys per kind.
for f in references/roles/*.md assets/template.role.md; do
  if grep -Eq '^kind: role' "$f" && has_keys "$f" "${role_keys[@]}"; then ok "shape role: $f"; else no "shape role: $f"; fi
done
for f in references/individuals/*.md assets/template.person.md; do
  if grep -Eq '^kind: individual' "$f" && has_keys "$f" "${person_keys[@]}"; then ok "shape person: $f"; else no "shape person: $f"; fi
done
# Each real individual's roles: must resolve to a role file (templates use placeholders, skip them).
for f in references/individuals/*.md; do
  slugs="$(sed -n 's/^roles:[[:space:]]*\[\(.*\)\].*/\1/p' "$f" | tr ',' '\n' | tr -d '[:space:]')"
  bad=""
  for slug in $slugs; do [[ -f "references/roles/${slug}.md" ]] || bad="$bad $slug"; done
  if [[ -z "$bad" ]]; then ok "roles resolve: $f"; else no "roles resolve: $f ->$bad"; fi
done

# 2. Script syntax.
if bash -n scripts/persona-review.sh; then ok "bash -n persona-review.sh"; else no "bash -n persona-review.sh"; fi

# 3. Arg-vector — a stub OUTFITTER_BIN prints the exec'd argv.
stub="$(mktemp)"
printf '#!/usr/bin/env bash\nprintf "%%s " "$@"\necho\n' >"$stub"
chmod +x "$stub"
argv="$(OUTFITTER_BIN="$stub" bash scripts/persona-review.sh \
  --persona references/roles/platform-lead.md \
  --persona references/individuals/priya-nair.md \
  -- --print '@README.md hi' 2>/dev/null)"
if grep -Eq 'run reviewer -- --append-system-prompt .*/references/roles/platform-lead\.md --append-system-prompt .*/references/individuals/priya-nair\.md --print @README\.md hi ' <<<"$argv"; then
  ok "arg-vector order + abspath + passthrough"
else
  no "arg-vector (got: $argv)"
fi

# 4. Exit codes.
[[ "$(exit_code env OUTFITTER_BIN="$stub" bash scripts/persona-review.sh -- --print x)" == 2 ]] && ok "exit 2: no --persona" || no "exit 2: no --persona"
[[ "$(exit_code env OUTFITTER_BIN="$stub" bash scripts/persona-review.sh --persona /no/such.md -- --print x)" == 1 ]] && ok "exit 1: missing persona file" || no "exit 1: missing persona file"
[[ "$(exit_code env OUTFITTER_BIN="$stub" bash scripts/persona-review.sh --persona references/roles/platform-lead.md junk -- --print x)" == 2 ]] && ok "exit 2: unexpected pre-'--' token" || no "exit 2: unexpected token"
[[ "$(exit_code env OUTFITTER_BIN="$stub" bash scripts/persona-review.sh --persona references/roles/platform-lead.md --)" == 2 ]] && ok "exit 2: no harness args" || no "exit 2: no harness args"
[[ "$(exit_code env OUTFITTER_BIN=definitely-not-a-real-bin bash scripts/persona-review.sh --persona references/roles/platform-lead.md -- --print x)" == 127 ]] && ok "exit 127: binary not on PATH" || no "exit 127: binary not found"
rm -f "$stub"

# 5. Resolution — reviewer agent + agent-local persona-review skill resolve via a path source.
if command -v "$outfitter_bin" >/dev/null 2>&1; then
  home="$(mktemp -d)"
  proj="$(mktemp -d)"
  mkdir -p "$proj/.agents"
  printf 'sources:\n  - path: %s\n' "$repo_root" >"$proj/.agents/settings.yml"
  if (cd "$proj" && HOME="$home" "$outfitter_bin" validate --strict >/dev/null 2>&1); then ok "validate --strict"; else no "validate --strict"; fi
  if (cd "$proj" && HOME="$home" "$outfitter_bin" list skills --agent reviewer 2>/dev/null) | grep -Eq 'persona-review .*agent-local'; then
    ok "list skills --agent reviewer shows persona-review [agent-local]"
  else
    no "list skills --agent reviewer"
  fi
  rm -rf "$home" "$proj"
else
  no "resolution: '$outfitter_bin' not on PATH (set OUTFITTER_BIN)"
fi

# 6. Live smoke (opt-in) — one real review must emit the fixed shape. Runs from a
# temp project that sources the catalog (so `reviewer` resolves) with the caller's
# real HOME (so the harness model/login is available); persona/artifact are absolute.
if [[ "${PERSONA_REVIEW_LIVE:-}" == "1" ]]; then
  smoke_proj="$(mktemp -d)"
  mkdir -p "$smoke_proj/.agents"
  printf 'sources:\n  - path: %s\n' "$repo_root" >"$smoke_proj/.agents/settings.yml"
  printf '# Sample artifact\n\nOutfitter composes layered .agents resources and launches an agent.\n' >"$smoke_proj/artifact.md"
  out="$(cd "$smoke_proj" && OUTFITTER_BIN="$outfitter_bin" bash "$skill_dir/scripts/persona-review.sh" \
    --persona "$skill_dir/references/roles/platform-lead.md" \
    --persona "$skill_dir/references/individuals/priya-nair.md" \
    -- --print "Return the standard persona-review shape. @artifact.md" 2>/dev/null || true)"
  rm -rf "$smoke_proj"
  miss=""
  for field in 'Persona' 'Artifact reviewed' 'First impression' 'Top blocker' 'Strongest value signal' 'Confusing language' 'Suggested change' 'Confidence'; do
    grep -qi "$field" <<<"$out" || miss="$miss; $field"
  done
  if [[ -z "$miss" ]]; then ok "live smoke: fixed 8-field shape"; else no "live smoke: missing$miss"; fi
else
  echo "  skip live smoke (set PERSONA_REVIEW_LIVE=1 to run a real model-backed review)"
fi

echo "---"
echo "passed: $pass  failed: $fail"
[[ "$fail" -eq 0 ]]
