#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/validate-workflows.sh /path/to/outfitter-cli.js" >&2
  exit 2
fi

catalog_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
validation_root=$(mktemp -d)
trap 'rm -rf "$validation_root"' EXIT HUP INT TERM
mkdir -p "$validation_root/home" "$validation_root/project"
ln -s "$catalog_root" "$validation_root/project/.agents"

(
  cd "$validation_root/project"
  HOME="$validation_root/home" node "$1" validate --strict
)
