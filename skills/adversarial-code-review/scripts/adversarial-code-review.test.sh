#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
catalog_root=$(cd -- "$script_dir/../../.." && pwd)
launcher="$script_dir/adversarial-code-review.sh"
validator="$catalog_root/agents/code-reviewer/skills/github-review-contract/scripts/validate-review.mjs"
fixture_root="$catalog_root/agents/code-reviewer/skills/github-review-contract/fixtures"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/diff" <<'DIFF'
diff --git a/src/example.ts b/src/example.ts
index 1111111..2222222 100644
--- a/src/example.ts
+++ b/src/example.ts
@@ -1 +1,2 @@
 old
+new
DIFF
node "$validator" "$fixture_root/request-changes.json" "$tmp/diff" 0123456789abcdef0123456789abcdef01234567 >/dev/null
node "$validator" "$fixture_root/approve.json" "$tmp/diff" 0123456789abcdef0123456789abcdef01234567 >/dev/null

mkdir -p "$tmp/repo" "$tmp/bin"
git -C "$tmp/repo" init -q
git -C "$tmp/repo" config user.email test@example.com
git -C "$tmp/repo" config user.name Test
printf 'old\n' >"$tmp/repo/example.txt"
git -C "$tmp/repo" add example.txt
git -C "$tmp/repo" commit -qm base
base=$(git -C "$tmp/repo" rev-parse HEAD)
printf 'old\nnew\n' >"$tmp/repo/example.txt"
git -C "$tmp/repo" commit -qam head
head=$(git -C "$tmp/repo" rev-parse HEAD)
printf 'review this\n' >"$tmp/instructions"
printf 'new line is safe\n' >"$tmp/requirements"

cat >"$tmp/bin/outfitter" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
: "${REVIEW_COUNT:?}"
[[ -z ${GITHUB_TOKEN-} && -z ${GH_TOKEN-} && -z ${GITHUB_PERSONAL_ACCESS_TOKEN-} && -z ${GITHUB_NOTIFY_TOKEN-} ]]
[[ -z ${GITHUB_WRITE_TOKEN-} && -z ${GH_ENTERPRISE_TOKEN-} && -z ${GITHUB_ENTERPRISE_TOKEN-} ]]
[[ -z ${GIT_ASKPASS-} && -z ${SSH_ASKPASS-} ]]
[[ -n ${GH_CONFIG_DIR-} && -d $GH_CONFIG_DIR ]]
printf 'x\n' >>"$REVIEW_COUNT"
[[ $1 == run && $2 == code-reviewer && $3 == --isolated && $4 == --append-prompt ]]
packet=$5
head=$(grep '^Head commit:' "$packet" | grep -o '[0-9a-f]\{40\}')
printf '{"commit_id":"%s","body":"No blocking findings in the pinned change.","event":"APPROVE","comments":[]}\n' "$head"
STUB
chmod +x "$tmp/bin/outfitter"
: >"$tmp/count"
(
  cd "$tmp/repo"
  PATH="$tmp/bin:$PATH" REVIEW_COUNT="$tmp/count" GITHUB_TOKEN=secret GH_TOKEN=secret \
    GITHUB_PERSONAL_ACCESS_TOKEN=secret GITHUB_NOTIFY_TOKEN=secret GITHUB_WRITE_TOKEN=secret \
    GH_ENTERPRISE_TOKEN=secret GITHUB_ENTERPRISE_TOKEN=secret GIT_ASKPASS=secret SSH_ASKPASS=secret \
    bash "$launcher" --base "$base" --head "$head" \
      --instructions-file "$tmp/instructions" --requirements-file "$tmp/requirements" \
      --output "$tmp/review.json" >/dev/null
)
[[ $(wc -l <"$tmp/count") -eq 1 ]]
[[ -s "$tmp/review.json" ]]
node -e 'const r=require(process.argv[1]); if(r.event!=="APPROVE") process.exit(1)' "$tmp/review.json"

echo 'adversarial-code-review tests passed'
