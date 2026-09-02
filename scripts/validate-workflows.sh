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

  HOME="$validation_root/home" node "$1" list workflows --json > "$validation_root/workflows.json"
  node -e '
    const fs = require("node:fs");
    const result = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    if (!result.ok) process.exit(1);
    for (const resource of result.resources) process.stdout.write(`${resource.slug}\n`);
  ' "$validation_root/workflows.json" > "$validation_root/workflows"

  expected=$(find "$catalog_root/workflows" -mindepth 2 -maxdepth 2 -name workflow.yaml | wc -l)
  actual=$(wc -l < "$validation_root/workflows")
  if [ "$actual" -ne "$expected" ]; then
    echo "enabled workflow count $actual does not match published workflow count $expected" >&2
    exit 1
  fi

  while IFS= read -r workflow; do
    HOME="$validation_root/home" node "$1" dump --workflow "$workflow" --out "$validation_root/first/$workflow"
    HOME="$validation_root/home" node "$1" dump --workflow "$workflow" --out "$validation_root/second/$workflow"
    diff -ru "$validation_root/first/$workflow" "$validation_root/second/$workflow"
  done < "$validation_root/workflows"
)
