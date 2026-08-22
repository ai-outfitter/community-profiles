#!/usr/bin/env bash
set -euo pipefail

hook_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
workspace="$(mktemp -d)"
trap 'rm -rf "$workspace"' EXIT

git -C "$workspace" init -q
git -C "$workspace" config user.name test
git -C "$workspace" config user.email test@example.invalid
git -C "$workspace" config commit.gpgsign false
mkdir -p "$workspace/agents/example" "$workspace/prompts" "$workspace/docs"
touch "$workspace/agents/example/agent.md" "$workspace/prompts/example.md" "$workspace/docs/example.md"
git -C "$workspace" add .
git -C "$workspace" commit -qm base

payload() {
  printf '{"version":1,"event":"stop","harness":"claude","workspace":"%s","hook":{"slug":"catalog-authoring","name":"catalog-authoring"},"continuation":{"active":%s,"supported":true}}\n' "$workspace" "$1"
}

printf 'change\n' >> "$workspace/docs/example.md"
payload false | "$hook_dir/scripts/remind.py"

printf 'change\n' >> "$workspace/agents/example/agent.md"
set +e
output="$(payload false | "$hook_dir/scripts/remind.py")"
status=$?
set -e
test "$status" -eq 2
test "$output" = "$(cat "$hook_dir/reminder.md")"

payload true | "$hook_dir/scripts/remind.py"

printf 'change\n' >> "$workspace/prompts/example.md"
set +e
payload false | "$hook_dir/scripts/remind.py" >/dev/null
status=$?
set -e
test "$status" -eq 2

git -C "$workspace" restore agents/example/agent.md prompts/example.md
mkdir -p "$workspace/agents/new"
touch "$workspace/agents/new/agent.md"
set +e
payload false | "$hook_dir/scripts/remind.py" >/dev/null
status=$?
set -e
test "$status" -eq 2
