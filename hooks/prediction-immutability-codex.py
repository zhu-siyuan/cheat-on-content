#!/usr/bin/env python3
"""Codex PreToolUse guard for immutable prediction sections."""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path


def deny(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            },
            ensure_ascii=False,
        )
    )
    raise SystemExit(0)


def prediction_section(path: Path) -> str:
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except Exception:
        return ""

    out: list[str] = []
    in_pred = False
    for line in lines:
        if line.startswith("## "):
            is_pred = bool(re.match(r"^## (预测|Prediction)(?:\b|\s|v\d|$)", line))
            if is_pred:
                in_pred = True
                out.append(line)
                continue
            if in_pred:
                break
        if in_pred:
            out.append(line)
    return "\n".join(out)


def patch_targets(patch: str):
    """Yield (action, path, block) for Git apply_patch style blocks."""
    header_re = re.compile(r"^\*\*\* (Update|Delete|Add) File: (.+)$", re.M)
    matches = list(header_re.finditer(patch))
    for i, match in enumerate(matches):
        start = match.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(patch)
        yield match.group(1), match.group(2).strip(), patch[start:end]


def is_prediction_path(raw: str) -> bool:
    normalized = raw.replace("\\", "/")
    return normalized.startswith("predictions/") or "/predictions/" in normalized


def check_apply_patch(command: str) -> None:
    for action, raw_path, block in patch_targets(command):
        if not is_prediction_path(raw_path):
            continue

        path = Path(raw_path)
        if action == "Add" and not path.exists():
            continue

        if action == "Delete":
            deny(
                f"Blind prediction protection: refusing to delete existing prediction file {raw_path}. "
                "Keep the original and create a new _redo.md file if a new prediction is required."
            )

        if not path.exists():
            continue

        locked = prediction_section(path)
        if not locked:
            continue

        locked_lines = {line for line in locked.splitlines() if line.strip()}
        touched_old_lines: list[str] = []
        for line in block.splitlines():
            if line.startswith("***") or line.startswith("@@"):
                continue
            if line.startswith("+") and not line.startswith("+++"):
                continue
            candidate = line[1:] if line.startswith(("-", " ")) else line
            if candidate.strip():
                touched_old_lines.append(candidate)

        if any(line in locked_lines for line in touched_old_lines):
            deny(
                f"Blind prediction protection: this edit touches the immutable prediction section in {raw_path}. "
                "Append retrospective/correction notes below the prediction, or create a separate _redo.md file."
            )


def check_bash(command: str) -> None:
    if "predictions/" not in command.replace("\\", "/"):
        return

    destructive = [
        r"\bsed\s+-[^\n]*i\b",
        r"\bperl\s+-[^\n]*pi\b",
        r"\btruncate\b",
        r"\brm\b",
        r"\bmv\b",
        r"\bcp\b[^\n]*\bpredictions/",
        r">\s*[^\n]*predictions/",
        r"\btee\b[^\n]*predictions/",
    ]
    if any(re.search(pattern, command) for pattern in destructive):
        deny(
            "Blind prediction protection: refusing a shell command that may overwrite or delete files under "
            "predictions/. Use the normal content workflow so only metadata/retrospective sections change."
        )


def main() -> None:
    if os.environ.get("CHEAT_BYPASS_IMMUTABILITY") == "1":
        return

    try:
        payload = json.load(sys.stdin)
    except Exception:
        return

    tool_name = str(payload.get("tool_name") or "")
    tool_input = payload.get("tool_input") or {}
    command = str(tool_input.get("command") or "")

    if tool_name == "apply_patch":
        check_apply_patch(command)
    elif tool_name == "Bash":
        check_bash(command)


if __name__ == "__main__":
    main()
