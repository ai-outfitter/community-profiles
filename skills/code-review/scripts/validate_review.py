#!/usr/bin/env python3
"""Validate a review envelope's inline-comment anchors against a diff.

usage: validate_review.py --diff pr.patch --review envelope.json [--head-sha SHA]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

HUNK_RE = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")
VALID_EVENTS = {"APPROVE", "COMMENT", "REQUEST_CHANGES"}
SEVERITY_RE = re.compile(r"^\[P[0-3]\] .+", re.DOTALL)


def diff_lines(patch: str) -> dict[str, dict[str, set[int]]]:
    """Map each path to its RIGHT (added) and LEFT (deleted) line numbers."""
    result: dict[str, dict[str, set[int]]] = {}
    path: str | None = None
    left = right = None

    for raw in patch.splitlines():
        if raw.startswith("+++ b/"):
            path = raw[6:]
            result.setdefault(path, {"RIGHT": set(), "LEFT": set()})
            left = right = None
            continue
        match = HUNK_RE.match(raw)
        if match:
            left, right = int(match.group(1)), int(match.group(2))
            continue
        if path is None or left is None or raw.startswith("\\"):
            continue
        if raw.startswith("+"):
            result[path]["RIGHT"].add(right)
            right += 1
        elif raw.startswith("-"):
            result[path]["LEFT"].add(left)
            left += 1
        else:
            left += 1
            right += 1

    return result


def validate(review: Any, allowed: dict[str, dict[str, set[int]]],
             expected_head: str | None) -> list[str]:
    errors: list[str] = []
    if not isinstance(review, dict):
        return ["envelope must be a JSON object"]

    if review.get("event") not in VALID_EVENTS:
        errors.append(f"event must be one of {sorted(VALID_EVENTS)}")
    commit_id = review.get("commit_id")
    if not isinstance(commit_id, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", commit_id or ""):
        errors.append("commit_id must be a 40-hex sha")
    elif expected_head and commit_id != expected_head:
        errors.append("commit_id does not match --head-sha")
    if not isinstance(review.get("body"), str) or not review["body"].strip():
        errors.append("body must be a non-empty string")

    comments = review.get("comments")
    if not isinstance(comments, list):
        return [*errors, "comments must be a JSON array"]
    if review.get("event") == "REQUEST_CHANGES" and not comments:
        errors.append("REQUEST_CHANGES carries at least one comment")

    seen: set[tuple[str, int, str]] = set()
    for index, comment in enumerate(comments):
        prefix = f"comments[{index}]"
        if not isinstance(comment, dict):
            errors.append(f"{prefix} must be an object")
            continue
        path, line, side, body = (comment.get(k) for k in ("path", "line", "side", "body"))
        if not isinstance(body, str) or not SEVERITY_RE.match(body or ""):
            errors.append(f"{prefix}.body must start with a [P0-3] severity prefix")
        if side not in ("RIGHT", "LEFT"):
            errors.append(f"{prefix}.side must be RIGHT or LEFT")
            continue
        if not isinstance(line, int) or isinstance(line, bool) or line < 1:
            errors.append(f"{prefix}.line must be a positive integer")
            continue
        if not isinstance(path, str) or not path:
            errors.append(f"{prefix}.path must be a non-empty string")
            continue
        anchor = (path, line, side)
        if anchor in seen:
            errors.append(f"{prefix} duplicates anchor {path}:{line}:{side}")
        seen.add(anchor)
        if path not in allowed:
            errors.append(f"{prefix}.path is not present in the diff: {path}")
        elif line not in allowed[path][side]:
            errors.append(f"{prefix} is not on a {side}-side diff line: {path}:{line}")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--diff", required=True, type=Path)
    parser.add_argument("--review", required=True, type=Path)
    parser.add_argument("--head-sha")
    args = parser.parse_args()

    review = json.loads(args.review.read_text(encoding="utf-8"))
    errors = validate(review, diff_lines(args.diff.read_text(encoding="utf-8")), args.head_sha)
    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1
    print(f"envelope valid: {len(review['comments'])} inline comment(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
