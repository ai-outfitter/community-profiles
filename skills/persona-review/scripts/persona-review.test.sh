#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/persona-review.sh"
fixture_dir="$(mktemp -d)"
stub="$fixture_dir/outfitter-stub"
trap 'rm -rf "$fixture_dir"' EXIT

printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$@"' >"$stub"
chmod +x "$stub"
printf '%s\n' 'persona' >"$fixture_dir/persona.md"

output="$(OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$fixture_dir/persona.md" \
  -- --print 'review this')"

expected="$(printf '%s\n' \
  run persona-reviewer -- \
  --append-system-prompt "$fixture_dir/persona.md" \
  --print 'review this')"

[[ "$output" == "$expected" ]] || {
  printf 'unexpected argument vector:\n%s\n' "$output" >&2
  exit 1
}

bash -n "$script"

if OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$fixture_dir/persona.md" \
  --persona "$fixture_dir/persona.md" \
  -- --print 'review this' >/dev/null 2>&1; then
  echo "multiple --persona arguments unexpectedly succeeded" >&2
  exit 1
fi

printf '%s\n' 'persona-review script checks passed'
