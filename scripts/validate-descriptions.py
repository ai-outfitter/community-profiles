#!/usr/bin/env python3
"""Reject agent and skill descriptions longer than 200 characters."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


MAX_DESCRIPTION_LENGTH = 200
RESOURCE_GLOBS = ("agents/**/agent.md", "skills/**/SKILL.md")


def frontmatter(text: str, path: Path) -> list[str]:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError(f"{path}: missing opening frontmatter delimiter")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError(f"{path}: missing closing frontmatter delimiter") from error
    return lines[1:end]


def description_value(lines: list[str], path: Path) -> str:
    for index, line in enumerate(lines):
        match = re.fullmatch(r"description:\s*(.*)", line)
        if not match:
            continue

        value = match.group(1)
        if value in {">", ">-", ">+", "|", "|-", "|+"}:
            block: list[str] = []
            for continuation in lines[index + 1 :]:
                if continuation and not continuation[0].isspace():
                    break
                block.append(continuation.strip())
            separator = " " if value.startswith(">") else "\n"
            return separator.join(block).strip()
        if value.startswith('"'):
            try:
                return json.loads(value)
            except json.JSONDecodeError as error:
                raise ValueError(f"{path}: invalid quoted description") from error
        if value.startswith("'") and value.endswith("'"):
            return value[1:-1].replace("''", "'")
        return value.strip()
    raise ValueError(f"{path}: missing description")


def resource_paths(root: Path) -> list[Path]:
    return sorted(path for pattern in RESOURCE_GLOBS for path in root.glob(pattern))


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    failures: list[str] = []
    for path in resource_paths(root):
        try:
            description = description_value(frontmatter(path.read_text(), path), path)
        except ValueError as error:
            failures.append(str(error))
            continue
        length = len(description)
        if length > MAX_DESCRIPTION_LENGTH:
            failures.append(
                f"{path.relative_to(root)}: description is {length} characters; "
                f"maximum is {MAX_DESCRIPTION_LENGTH}"
            )

    if failures:
        print("Description validation failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    print(f"Descriptions are at most {MAX_DESCRIPTION_LENGTH} characters.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
