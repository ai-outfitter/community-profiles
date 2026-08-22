#!/usr/bin/env python3
"""Remind an agent about catalog boundaries after relevant edits."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def relevant(path: str) -> bool:
    parts = Path(path).parts
    return (
        len(parts) == 3
        and parts[0] == "agents"
        and parts[2] == "agent.md"
    ) or (len(parts) == 2 and parts[0] == "prompts" and parts[1].endswith(".md"))


def changed_paths(workspace: Path) -> list[str]:
    result = subprocess.run(
        ["git", "status", "--porcelain=v1", "-z", "--untracked-files=all"],
        cwd=workspace,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []

    paths: list[str] = []
    entries = result.stdout.split("\0")
    index = 0
    while index < len(entries):
        entry = entries[index]
        index += 1
        if not entry:
            continue
        status = entry[:2]
        paths.append(entry[3:])
        if "R" in status or "C" in status:
            if index < len(entries) and entries[index]:
                paths.append(entries[index])
                index += 1
    return paths


def main() -> int:
    try:
        event = json.load(sys.stdin)
        if event.get("event") != "stop":
            return 0
        continuation = event.get("continuation", {})
        if not isinstance(continuation, dict) or continuation.get("active") is True:
            return 0
        workspace_value = event.get("workspace")
        if not isinstance(workspace_value, str):
            return 0
        workspace = Path(workspace_value)
        if not workspace.is_dir():
            return 0
        if not any(relevant(path) for path in changed_paths(workspace)):
            return 0
        reminder = Path(__file__).resolve().parent.parent / "reminder.md"
        print(reminder.read_text(encoding="utf-8").strip())
        return 2
    except (json.JSONDecodeError, OSError, ValueError):
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
