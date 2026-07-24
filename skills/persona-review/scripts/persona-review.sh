#!/usr/bin/env bash
# Launch one shared persona agent with one canonical persona file appended.
set -euo pipefail

outfitter_bin="${OUTFITTER_BIN:-outfitter}"
agent="persona-reviewer"
persona_file=""

usage() {
  cat <<'EOF'
Usage: persona-review.sh [--agent <slug>] --persona <file> -- <harness arguments...>
EOF
}

abspath() {
  local dir base
  dir="$(cd "$(dirname "$1")" && pwd)"
  base="$(basename "$1")"
  printf '%s/%s\n' "$dir" "$base"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      agent="$2"
      shift 2
      ;;
    --persona)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      [[ -z "$persona_file" ]] || {
        echo "persona-review: exactly one --persona <file> is allowed" >&2
        exit 2
      }
      [[ -f "$2" ]] || {
        echo "persona-review: persona document not found: $2" >&2
        exit 1
      }
      persona_file="$(abspath "$2")"
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
  echo "persona-review: exactly one --persona <file> is required" >&2
  exit 2
}
[[ $# -gt 0 ]] || {
  echo "persona-review: harness arguments are required after --" >&2
  exit 2
}
command -v "$outfitter_bin" >/dev/null 2>&1 || {
  echo "persona-review: '$outfitter_bin' is not on PATH" >&2
  exit 127
}

exec "$outfitter_bin" run "$agent" -- --append-system-prompt "$persona_file" "$@"
