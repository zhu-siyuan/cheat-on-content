#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/install-codex.sh"
bash -n "$ROOT/uninstall-codex.sh"
bash -n "$ROOT/hooks/session-start.sh"
python3 -m py_compile "$ROOT/hooks/prediction-immutability-codex.py"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
mkdir -p predictions
cat > predictions/test.md <<'EOF'
# Test

## 预测
locked line

## 复盘
old retro
EOF

deny_payload=$(cat <<'EOF'
{"tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: predictions/test.md\n@@\n-locked line\n+changed prediction\n*** End Patch"}}
EOF
)
deny_out=$(printf '%s' "$deny_payload" | python3 "$ROOT/hooks/prediction-immutability-codex.py")
printf '%s' "$deny_out" | grep -q '"permissionDecision": "deny"'

allow_payload=$(cat <<'EOF'
{"tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: predictions/test.md\n@@\n-old retro\n+new retro\n*** End Patch"}}
EOF
)
allow_out=$(printf '%s' "$allow_payload" | python3 "$ROOT/hooks/prediction-immutability-codex.py")
[[ -z "$allow_out" ]]

bash_payload='{"tool_name":"Bash","tool_input":{"command":"rm predictions/test.md"}}'
bash_out=$(printf '%s' "$bash_payload" | python3 "$ROOT/hooks/prediction-immutability-codex.py")
printf '%s' "$bash_out" | grep -q '"permissionDecision": "deny"'

echo "codex-native checks passed"
