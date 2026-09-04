#!/bin/sh
# Anchors validate against the file each hunk belongs to, deleted files included.
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cat > "$work/diff.patch" <<'EOF'
diff --git a/kept.txt b/kept.txt
index 000000..111111 100644
--- a/kept.txt
+++ b/kept.txt
@@ -1,2 +1,2 @@
-old line
+new line
 context
diff --git a/removed.txt b/removed.txt
deleted file mode 100644
index 222222..000000
--- a/removed.txt
+++ /dev/null
@@ -1,2 +0,0 @@
-gone one
-gone two
diff --git a/added.txt b/added.txt
new file mode 100644
index 000000..333333
--- /dev/null
+++ b/added.txt
@@ -0,0 +1 @@
+fresh
EOF

sha=0123456789abcdef0123456789abcdef01234567

# Valid: RIGHT on the kept file, LEFT on the deleted file, RIGHT on the new file.
cat > "$work/good.json" <<EOF
{"commit_id": "$sha", "event": "COMMENT", "body": "COMMENT\n\nclean",
 "comments": [
  {"path": "kept.txt", "line": 1, "side": "RIGHT", "body": "[P3] a"},
  {"path": "removed.txt", "line": 2, "side": "LEFT", "body": "[P2] b"},
  {"path": "added.txt", "line": 1, "side": "RIGHT", "body": "[P3] c"}
 ]}
EOF
python3 "$script_dir/validate_review.py" --diff "$work/diff.patch" --review "$work/good.json" --head-sha "$sha"

# Invalid: the deleted file's lines must not leak onto the next file's map,
# and a deleted file has no RIGHT side.
cat > "$work/bad.json" <<EOF
{"commit_id": "$sha", "event": "COMMENT", "body": "COMMENT\n\nclean",
 "comments": [
  {"path": "removed.txt", "line": 1, "side": "RIGHT", "body": "[P2] x"},
  {"path": "kept.txt", "line": 2, "side": "LEFT", "body": "[P2] y"}
 ]}
EOF
if python3 "$script_dir/validate_review.py" --diff "$work/diff.patch" --review "$work/bad.json" --head-sha "$sha" 2>/dev/null; then
  echo "FAIL: invalid anchors were accepted" >&2
  exit 1
fi

echo ok
