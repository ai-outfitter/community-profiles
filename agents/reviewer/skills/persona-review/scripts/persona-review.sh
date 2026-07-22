#!/usr/bin/env bash
# persona-review.sh — run a persona review as its own composed reviewer process.
#
# Spawns `outfitter run <agent>` with the selected persona description
# document(s) passed through to the harness as `--append-system-prompt`. Because
# Outfitter appends pass-through args last, the child is the fully composed
# reviewer (its own system prompt, the persona-review skill, and the profile's
# model) with the persona layered on top. The base agent stays fixed; only the
# appended persona varies per run, so runs stay directly comparable.
#
# Usage:
#   bash persona-review.sh [--agent <slug>] --persona <doc> [--persona <doc>...] -- <harness args...>
#
#   --agent <slug>   Agent to compose (default: reviewer).
#   --persona <doc>  Persona description document appended to the composed
#                    system prompt. Repeatable; give the role first, then the
#                    individual, so the individual refines the role. Paths are
#                    resolved to absolute so they work from the child's cwd.
#   after --         Passed straight to the harness. Include `--print` for a
#                    non-interactive run and the review task; attach the
#                    artifact with pi's @-syntax, placing the @path LAST in the
#                    prompt (pi reads an @ reference to the end of the string).
#
# Example:
#   bash persona-review.sh \
#     --persona references/roles/platform-lead.md \
#     --persona references/individuals/priya-nair.md \
#     -- --print "Return the standard persona-review shape. @README.md"
set -euo pipefail

outfitter_bin="${OUTFITTER_BIN:-outfitter}"
if ! command -v "$outfitter_bin" >/dev/null 2>&1; then
  echo "persona-review: '$outfitter_bin' is not on PATH. Install Outfitter or set OUTFITTER_BIN." >&2
  exit 127
fi

abspath() { # portable realpath for an existing file
  local dir base
  dir="$(cd "$(dirname "$1")" && pwd)" || return 1
  base="$(basename "$1")"
  printf '%s/%s\n' "$dir" "$base"
}

agent="reviewer"
append_args=()   # --append-system-prompt <abs doc> pairs
persona_count=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      [[ $# -ge 2 ]] || { echo "persona-review: --agent needs a value" >&2; exit 2; }
      agent="$2"; shift 2 ;;
    --persona)
      [[ $# -ge 2 ]] || { echo "persona-review: --persona needs a path" >&2; exit 2; }
      if [[ ! -f "$2" ]]; then
        echo "persona-review: persona document not found: $2" >&2
        exit 1
      fi
      append_args+=(--append-system-prompt "$(abspath "$2")")
      persona_count=$((persona_count + 1))
      shift 2 ;;
    --)
      shift; break ;;
    *)
      echo "persona-review: unexpected argument '$1' (put harness args after --)" >&2
      exit 2 ;;
  esac
done

if [[ $persona_count -eq 0 ]]; then
  echo "persona-review: at least one --persona <doc> is required" >&2
  exit 2
fi

if [[ $# -eq 0 ]]; then
  echo "persona-review: no harness args given (pass them after --, e.g. -- --print \"@README.md ...\")" >&2
  exit 2
fi

# outfitter run <agent> -- <persona appends> <caller's harness args>
exec "$outfitter_bin" run "$agent" -- "${append_args[@]}" "$@"
