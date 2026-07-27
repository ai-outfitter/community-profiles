#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/persona-review.sh"
fixture_dir="$(cd "$(mktemp -d)" && pwd)"
stub="$fixture_dir/outfitter-stub"
trap 'rm -rf "$fixture_dir"' EXIT

printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$@"' >"$stub"
chmod +x "$stub"
mkdir "$fixture_dir/with space"
printf '%s\n' 'persona' >"$fixture_dir/with space/persona.md"

bash -n "$script"

output="$(OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$fixture_dir/with space/persona.md" \
  -- --print 'review this')"

expected="$(printf '%s\n' \
  run persona-reviewer -- \
  --append-system-prompt "$fixture_dir/with space/persona.md" \
  --print 'review this')"

[[ "$output" == "$expected" ]] || {
  printf 'unexpected argument vector:\n%s\n' "$output" >&2
  exit 1
}

output="$(OUTFITTER_BIN="$stub" bash "$script" \
  --agent other-reviewer \
  --persona "$fixture_dir/with space/persona.md" \
  -- --print 'review this')"

[[ "$output" == "$(printf '%s\n' \
  run other-reviewer -- \
  --append-system-prompt "$fixture_dir/with space/persona.md" \
  --print 'review this')" ]] || {
  printf 'unexpected --agent argument vector:\n%s\n' "$output" >&2
  exit 1
}

rc=0
OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$fixture_dir/with space/persona.md" \
  --persona "$fixture_dir/with space/persona.md" \
  -- --print 'review this' >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 2 ]] || {
  echo "duplicate --persona expected exit 2, got $rc" >&2
  exit 1
}

rc=0
OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$fixture_dir/missing.md" \
  -- --print 'review this' >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 1 ]] || {
  echo "missing persona file expected exit 1, got $rc" >&2
  exit 1
}

rc=0
OUTFITTER_BIN="$stub" bash "$script" \
  --agent '' \
  --persona "$fixture_dir/with space/persona.md" \
  -- --print 'review this' >/dev/null 2>&1 || rc=$?
[[ "$rc" -eq 2 ]] || {
  echo "empty --agent expected exit 2, got $rc" >&2
  exit 1
}

printf '%s\n' 'persona-review script checks passed'
