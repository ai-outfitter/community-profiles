#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script="$script_dir/persona-review.sh"
fixture_dir="$(mktemp -d)"
stub="$fixture_dir/outfitter-stub"
trap 'rm -rf "$fixture_dir"' EXIT

printf '%s\n' \
  '#!/usr/bin/env bash' \
  'if [[ "${OUTFITTER_STUB_READ_STDIN:-0}" -eq 1 ]]; then' \
  '  IFS= read -r input' \
  '  printf "stdin:%s\n" "$input"' \
  'elif [[ "${OUTFITTER_STUB_SILENT:-0}" -ne 1 ]]; then' \
  '  printf "%s\n" "$@"' \
  'fi' \
  'exit "${OUTFITTER_STUB_EXIT:-0}"' >"$stub"
chmod +x "$stub"
mkdir "$fixture_dir/with space"
persona="$fixture_dir/with space/persona.md"
report="$fixture_dir/with space/report.md"
printf '%s\n' 'persona' >"$persona"

# expect_report <expected-report> <label> <script arguments...>
expect_report() {
  local expected="$1" label="$2" actual
  shift 2
  rm -f "$report"
  OUTFITTER_BIN="$stub" bash "$script" "$@"
  actual="$(<"$report")"
  [[ "$actual" == "$expected" ]] || {
    printf 'unexpected %s report:\n%s\n' "$label" "$actual" >&2
    exit 1
  }
}

# expect_rc <expected-status> <label> <script arguments...>
expect_rc() {
  local want="$1" label="$2" rc=0
  shift 2
  OUTFITTER_BIN="$stub" bash "$script" "$@" >/dev/null 2>&1 || rc=$?
  [[ "$rc" -eq "$want" ]] || {
    echo "$label expected exit $want, got $rc" >&2
    exit 1
  }
}

bash -n "$script"

expect_report "$(printf '%s\n' \
  run persona-reviewer -- \
  --append-system-prompt "$persona" \
  --print 'review this')" \
  'saved' \
  --persona "$persona" --report "$report" -- --print 'review this'

expect_report "$(printf '%s\n' \
  run other-reviewer -- \
  --append-system-prompt "$persona" \
  --print 'review this')" \
  '--agent saved' \
  --agent other-reviewer --persona "$persona" --report "$report" \
  -- --print 'review this'

rm -f "$report"
printf '%s\n' 'piped prompt' |
  OUTFITTER_STUB_READ_STDIN=1 OUTFITTER_BIN="$stub" bash "$script" \
    --persona "$persona" --report "$report" -- --print
[[ "$(<"$report")" == 'stdin:piped prompt' ]] || {
  echo "launcher did not preserve piped stdin" >&2
  exit 1
}

printf '%s\n' 'previous report' >"$report"
chmod 0640 "$report"
OUTFITTER_BIN="$stub" bash "$script" \
  --persona "$persona" --report "$report" -- --print 'review this'
[[ "$(stat -c '%a' "$report" 2>/dev/null || stat -f '%Lp' "$report")" == 640 ]] || {
  echo "updated report did not preserve its file mode" >&2
  exit 1
}

expect_rc 2 'duplicate --persona' \
  --persona "$persona" --persona "$persona" --report "$report" \
  -- --print 'review this'

expect_rc 1 'missing persona file' \
  --persona "$fixture_dir/missing.md" --report "$report" \
  -- --print 'review this'

expect_rc 2 'empty --agent' \
  --agent '' --persona "$persona" --report "$report" \
  -- --print 'review this'

expect_rc 2 'missing --report' \
  --persona "$persona" -- --print 'review this'

expect_rc 2 'duplicate --report' \
  --persona "$persona" --report "$report" --report "$report" \
  -- --print 'review this'

expect_rc 1 'missing report parent' \
  --persona "$persona" --report "$fixture_dir/missing/report.md" \
  -- --print 'review this'

report_target="$fixture_dir/with space/report-target.md"
report_link="$fixture_dir/with space/report-link.md"
printf '%s\n' 'target report' >"$report_target"
ln -s "$report_target" "$report_link"
expect_rc 1 'symbolic-link report' \
  --persona "$persona" --report "$report_link" \
  -- --print 'review this'
[[ "$(<"$report_target")" == 'target report' ]] || {
  echo "symbolic-link report changed its target" >&2
  exit 1
}

expect_rc 2 'interactive harness arguments' \
  --persona "$persona" --report "$report" \
  -- --model inherited

expect_report "$(printf '%s\n' \
  run persona-reviewer -- \
  --append-system-prompt "$persona" \
  -p 'review this')" \
  'short print flag' \
  --persona "$persona" --report "$report" -- -p 'review this'

persona_before="$(<"$persona")"
expect_rc 1 'report path collides with persona' \
  --persona "$persona" --report "$persona" \
  -- --print 'review this'
[[ "$(<"$persona")" == "$persona_before" ]] || {
  echo "persona was changed by a colliding report path" >&2
  exit 1
}

printf '%s\n' 'previous report' >"$report"
export OUTFITTER_STUB_EXIT=23
expect_rc 23 'Outfitter failure' \
  --persona "$persona" --report "$report" \
  -- --print 'review this'
unset OUTFITTER_STUB_EXIT
[[ "$(<"$report")" == 'previous report' ]] || {
  echo "failed review replaced the previous durable report" >&2
  exit 1
}

export OUTFITTER_STUB_SILENT=1
expect_rc 1 'empty successful review' \
  --persona "$persona" --report "$report" \
  -- --print 'review this'
unset OUTFITTER_STUB_SILENT
[[ "$(<"$report")" == 'previous report' ]] || {
  echo "empty successful review replaced the previous durable report" >&2
  exit 1
}

shopt -s nullglob
report_temps=("${report}.tmp."*)
[[ "${#report_temps[@]}" -eq 0 ]] || {
  echo "failed review left a temporary report behind" >&2
  exit 1
}

printf '%s\n' 'persona-review script checks passed'
