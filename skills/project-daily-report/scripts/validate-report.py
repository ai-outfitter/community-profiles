#!/usr/bin/env python3
"""Validate the mechanical parts of the project daily report contract."""

from __future__ import annotations

import re
import sys
from pathlib import Path

HEADINGS = [
    "## Needs attention",
    "## Project movement",
    "## Bench",
    "## Next 24 hours",
    "## Coverage gaps",
]
LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
TITLE = re.compile(r"^# .+ — \d{4}-\d{2}-\d{2}$")
COVERAGE = re.compile(r"^_Coverage: .+ through .+_$")


def validate(text: str) -> list[str]:
    errors: list[str] = []
    lines = text.splitlines()
    words = re.findall(r"\b[\w’'-]+\b", text)

    if not lines or not TITLE.fullmatch(lines[0]):
        errors.append("title must end with an ISO edition date")
    if len(lines) < 2 or not COVERAGE.fullmatch(lines[1]):
        errors.append("coverage line must state both cutoffs")
    if len(words) < 300 or len(words) > 500:
        errors.append(f"report has {len(words)} words; expected 300-500")

    heading_lines = [line for line in lines if line.startswith("## ")]
    if heading_lines != HEADINGS:
        errors.append("report must contain every required section")

    for index, heading in enumerate(HEADINGS):
        try:
            start = lines.index(heading)
        except ValueError:
            continue
        end = (
            lines.index(HEADINGS[index + 1])
            if index + 1 < len(HEADINGS) and HEADINGS[index + 1] in lines
            else len(lines)
        )
        items = [line for line in lines[start + 1 : end] if line.strip()]
        if not items:
            errors.append(f"{heading} is empty")
            continue
        for item in items:
            if not item.startswith("- "):
                errors.append(f"{heading} contains content outside a list item")
                continue
            if item == "- No material change":
                continue
            links = LINK.findall(item)
            if not links:
                errors.append(f"{heading} has a material item without a supporting link")
                continue
            for target in links:
                if not safe_link(target):
                    errors.append(f"{heading} contains an unsafe link")

    return errors


def safe_link(target: str) -> bool:
    if target.startswith("https://"):
        return True
    if target.startswith(("/", "//")) or ":" in target.split("/", 1)[0]:
        return False
    return bool(
        re.fullmatch(
            r"(?:\.\.?/)?[A-Za-z0-9._~!$&'()*+,;=@%/-]+"
            r"(?:#[A-Za-z0-9._~!$&'()*+,;=:@%/?-]+)?",
            target,
        )
    )


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate-report.py REPORT.md", file=sys.stderr)
        return 2
    report = Path(sys.argv[1])
    if not report.is_file():
        print(f"report does not exist: {report}", file=sys.stderr)
        return 2
    errors = validate(report.read_text(encoding="utf-8"))
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
