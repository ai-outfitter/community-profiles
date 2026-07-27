#!/usr/bin/env bash
# Launch one shared persona agent with one canonical persona file appended,
# saving the finite process's stdout at the caller-selected report path.
set -euo pipefail

outfitter_bin="${OUTFITTER_BIN:-outfitter}"
agent="persona-reviewer"
persona_file=""
report_file=""

usage() {
  cat <<'EOF'
Usage: persona-review.sh [--agent <slug>] --persona <file> --report <file> -- <harness arguments...>
EOF
}

# Resolve a path whose parent directory must already exist.
abspath() {
  local dir base
  dir="$(CDPATH='' cd -P -- "$(dirname -- "$1")" >/dev/null 2>&1 && pwd -P)" || return 1
  [[ -n "$dir" ]] || return 1
  base="${1##*/}"
  [[ -n "$base" ]] || return 1
  printf '%s\n' "${dir%/}/$base"
}

file_mode() {
  local mode
  if mode="$(stat -c '%a' "$1" 2>/dev/null)"; then
    printf '%s\n' "$mode"
  elif mode="$(stat -f '%Lp' "$1" 2>/dev/null)"; then
    printf '%s\n' "$mode"
  else
    return 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 && -n "$2" ]] || {
        echo "persona-review: --agent requires a non-empty slug" >&2
        exit 2
      }
      agent="$2"
      shift 2
      ;;
    --persona)
      [[ $# -ge 2 && -n "$2" ]] || {
        echo "persona-review: --persona requires a non-empty file path" >&2
        exit 2
      }
      [[ -z "$persona_file" ]] || {
        echo "persona-review: exactly one --persona <file> is allowed" >&2
        exit 2
      }
      [[ -f "$2" && -r "$2" ]] || {
        echo "persona-review: persona document is not a readable file: $2" >&2
        exit 1
      }
      persona_file="$(abspath "$2")" || {
        echo "persona-review: cannot resolve persona path: $2" >&2
        exit 1
      }
      shift 2
      ;;
    --report)
      [[ $# -ge 2 && -n "$2" ]] || {
        echo "persona-review: --report requires a non-empty file path" >&2
        exit 2
      }
      [[ -z "$report_file" ]] || {
        echo "persona-review: exactly one --report <file> is allowed" >&2
        exit 2
      }
      report_file="$(abspath "$2")" || {
        echo "persona-review: report parent must be an existing readable directory: $2" >&2
        exit 1
      }
      [[ ! -L "$report_file" ]] || {
        echo "persona-review: report path must not be a symbolic link: $2" >&2
        exit 1
      }
      [[ ! -d "$report_file" ]] || {
        echo "persona-review: report path is a directory: $2" >&2
        exit 1
      }
      [[ ! -e "$report_file" || -w "$report_file" ]] || {
        echo "persona-review: report file is not writable: $2" >&2
        exit 1
      }
      report_parent="${report_file%/*}"
      [[ -w "${report_parent:-/}" ]] || {
        echo "persona-review: report parent is not writable: $2" >&2
        exit 1
      }
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "persona-review: unexpected argument '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "$persona_file" ]] || {
  echo "persona-review: --persona <file> is required" >&2
  exit 2
}
[[ -n "$report_file" ]] || {
  echo "persona-review: --report <file> is required" >&2
  exit 2
}
[[ $# -gt 0 ]] || {
  echo "persona-review: harness arguments are required after --" >&2
  exit 2
}
finite_run=0
for argument in "$@"; do
  case "$argument" in
    -p|--print|-p=*|--print=*) finite_run=1 ;;
  esac
done
[[ "$finite_run" -eq 1 ]] || {
  echo "persona-review: finite Pi/Claude reviews require --print or -p" >&2
  exit 2
}
[[ "$report_file" != "$persona_file" ]] || {
  echo "persona-review: report path must differ from persona path" >&2
  exit 1
}
command -v "$outfitter_bin" >/dev/null 2>&1 || {
  echo "persona-review: '$outfitter_bin' is not on PATH" >&2
  exit 127
}

if [[ -e "$report_file" ]]; then
  report_mode="$(file_mode "$report_file")" || {
    echo "persona-review: cannot read report file mode: $report_file" >&2
    exit 1
  }
else
  current_umask="$(umask)"
  printf -v report_mode '%03o' "$((0666 & ~(8#$current_umask)))"
fi

report_tmp="$(mktemp "${report_file}.tmp.XXXXXX")" || {
  echo "persona-review: cannot create temporary report beside: $report_file" >&2
  exit 1
}
reviewer_pid=""
cleanup() {
  rm -f "$report_tmp"
}
forward_signal() {
  local signal="$1" status="$2"
  if [[ -n "$reviewer_pid" ]]; then
    kill -s "$signal" "$reviewer_pid" 2>/dev/null || true
    wait "$reviewer_pid" 2>/dev/null || true
  fi
  exit "$status"
}
trap cleanup EXIT
trap 'forward_signal HUP 129' HUP
trap 'forward_signal INT 130' INT
trap 'forward_signal TERM 143' TERM

status=0
"$outfitter_bin" run "$agent" -- \
  --append-system-prompt "$persona_file" "$@" <&0 >"$report_tmp" &
reviewer_pid=$!
wait "$reviewer_pid" || status=$?
reviewer_pid=""
[[ "$status" -eq 0 ]] || exit "$status"
[[ -s "$report_tmp" ]] || {
  echo "persona-review: reviewer completed without producing a report" >&2
  exit 1
}

trap - EXIT HUP INT TERM
chmod "$report_mode" "$report_tmp" || {
  echo "persona-review: cannot preserve report mode; completed output remains at: $report_tmp" >&2
  exit 1
}
mv -f "$report_tmp" "$report_file" || {
  echo "persona-review: cannot publish report; completed output remains at: $report_tmp" >&2
  exit 1
}
