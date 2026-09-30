#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DST="$HOME/.agents/skills"
HOOKS_DST="$HOME/.codex/hooks/cheat-on-content"
HOOKS_JSON="$HOME/.codex/hooks.json"

SUB_SKILLS=(
  cheat-init cheat-learn-from cheat-seed cheat-score cheat-score-blind
  cheat-predict cheat-shoot cheat-publish cheat-retro cheat-persona
  cheat-bump cheat-recommend cheat-trends cheat-status cheat-migrate
)

mkdir -p "$SKILLS_DST" "$HOOKS_DST" "$HOME/.codex"

install_one() {
  local name="$1"
  local src="$ROOT/skills/$name"
  local dst="$SKILLS_DST/$name"
  [[ -f "$src/SKILL.md" ]] || { echo "Missing $src/SKILL.md"; exit 1; }
  rm -rf "$dst"
  ln -s "$src" "$dst"
  echo "linked $name"
}

install_one content-operator
for name in "${SUB_SKILLS[@]}"; do
  install_one "$name"
done

cp "$ROOT/hooks/session-start.sh" "$HOOKS_DST/session-start.sh"
cp "$ROOT/hooks/prediction-immutability-codex.py" "$HOOKS_DST/prediction-immutability-codex.py"
chmod +x "$HOOKS_DST/session-start.sh" "$HOOKS_DST/prediction-immutability-codex.py"

python3 - "$HOOKS_JSON" "$HOOKS_DST" <<'PY'
import json, sys
from pathlib import Path

config = Path(sys.argv[1])
hook_dir = Path(sys.argv[2])
data = {}
if config.exists():
    data = json.loads(config.read_text(encoding="utf-8"))

hooks = data.setdefault("hooks", {})

def remove_ours(groups):
    out = []
    for group in groups or []:
        commands = [
            str(h.get("command", ""))
            for h in group.get("hooks", [])
            if isinstance(h, dict)
        ]
        if any("cheat-on-content" in cmd for cmd in commands):
            continue
        out.append(group)
    return out

session = remove_ours(hooks.get("SessionStart", []))
session.append({
    "matcher": "startup|resume|clear|compact",
    "hooks": [{
        "type": "command",
        "command": f'bash "{hook_dir / "session-start.sh"}" --codex',
        "statusMessage": "Loading content project context",
        "additionalContextLimit": 2500
    }]
})
hooks["SessionStart"] = session

pre = remove_ours(hooks.get("PreToolUse", []))
pre.append({
    "matcher": "Edit|Write|Bash",
    "hooks": [{
        "type": "command",
        "command": f'python3 "{hook_dir / "prediction-immutability-codex.py"}"',
        "timeout": 5,
        "statusMessage": "Protecting blind predictions"
    }]
})
hooks["PreToolUse"] = pre

data.setdefault("description", "User lifecycle hooks (includes cheat-on-content).")
config.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

echo
echo "Codex-native cheat-on-content installed."
echo "Skills: $SKILLS_DST"
echo "Hooks:  $HOOKS_JSON"
echo
echo "Open Codex in a content project and just describe what you want to make."
echo 'Example: 我有个想法，想拍一期“为什么具身智能还没有 GPT-3 moment”'
echo
echo "Codex may ask you once to review/trust the new hook definitions."
