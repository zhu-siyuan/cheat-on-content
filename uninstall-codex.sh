#!/usr/bin/env bash
set -euo pipefail

SKILLS_DST="$HOME/.agents/skills"
HOOKS_DST="$HOME/.codex/hooks/cheat-on-content"
HOOKS_JSON="$HOME/.codex/hooks.json"

SUB_SKILLS=(
  content-operator
  cheat-init cheat-learn-from cheat-seed cheat-score cheat-score-blind
  cheat-predict cheat-shoot cheat-publish cheat-retro cheat-persona
  cheat-bump cheat-recommend cheat-trends cheat-status cheat-migrate
)

for name in "${SUB_SKILLS[@]}"; do
  target="$SKILLS_DST/$name"
  if [[ -L "$target" || -d "$target" ]]; then
    rm -rf "$target"
    echo "removed $target"
  fi
done

rm -rf "$HOOKS_DST"

if [[ -f "$HOOKS_JSON" ]] && command -v python3 >/dev/null 2>&1; then
  python3 - "$HOOKS_JSON" <<'PY'
import json, sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
hooks = data.get("hooks", {})

for event in ("SessionStart", "PreToolUse"):
    kept = []
    for group in hooks.get(event, []) or []:
        commands = [
            str(h.get("command", ""))
            for h in group.get("hooks", [])
            if isinstance(h, dict)
        ]
        if any("cheat-on-content" in cmd for cmd in commands):
            continue
        kept.append(group)
    if kept:
        hooks[event] = kept
    else:
        hooks.pop(event, None)

if hooks:
    data["hooks"] = hooks
else:
    data.pop("hooks", None)

path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
fi

echo
echo "Codex-native cheat-on-content removed."
echo "Content project data was not touched."
