#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
validator="$script_dir/validate-report.py"
fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT

make_report() {
  local path="$1" words="$2"
  {
    printf '%s\n' '# Example Daily — 2026-08-16'
    printf '%s\n\n' '_Coverage: previous 08:00 CT through current 08:00 CT_'
    for heading in 'Needs attention' 'Project movement' 'Bench' 'Next 24 hours' 'Coverage gaps'; do
      printf '## %s\n' "$heading"
      printf -- '- [Evidence](https://example.invalid/evidence) '
      seq "$words" | sed 's/.*/supported /' | tr -d '\n'
      printf '\n\n'
    done
  } >"$path"
}

make_report "$fixture_dir/normal.md" 54
python3 "$validator" "$fixture_dir/normal.md"

cp "$fixture_dir/normal.md" "$fixture_dir/missing-links.md"
sed -i '0,/\[Evidence\](https:\/\/example.invalid\/evidence) /s///' "$fixture_dir/missing-links.md"
! python3 "$validator" "$fixture_dir/missing-links.md" >/dev/null 2>&1

make_report "$fixture_dir/over-length.md" 110
! python3 "$validator" "$fixture_dir/over-length.md" >/dev/null 2>&1

cp "$fixture_dir/normal.md" "$fixture_dir/out-of-order.md"
sed -i 's/## Needs attention/## Needs attention extra/' "$fixture_dir/out-of-order.md"
! python3 "$validator" "$fixture_dir/out-of-order.md" >/dev/null 2>&1

cp "$fixture_dir/normal.md" "$fixture_dir/unsafe-link.md"
sed -i '0,/https:\/\/example.invalid\/evidence/s//javascript:\/\/alert/' "$fixture_dir/unsafe-link.md"
! python3 "$validator" "$fixture_dir/unsafe-link.md" >/dev/null 2>&1

PYTHONPYCACHEPREFIX="$fixture_dir/pycache" python3 -m py_compile "$validator"
