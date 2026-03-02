#!/usr/bin/env bash
set -euo pipefail

settings_file="${1:-$HOME/.claude/settings.json}"
settings_dir="$(dirname "$settings_file")"
tmp_input="$(mktemp)"
tmp_output="$(mktemp)"

trap 'rm -f "$tmp_input" "$tmp_output"' EXIT

mkdir -p "$settings_dir"

if [[ -f "$settings_file" ]]; then
  if ! jq -e . "$settings_file" >/dev/null 2>&1; then
    echo "Error: invalid JSON in $settings_file" >&2
    exit 1
  fi
  cp "$settings_file" "$tmp_input"
else
  printf '{}\n' >"$tmp_input"
fi

jq '
  .hooks = {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/wsl-notify.sh"
          }
        ]
      }
    ]
  }
  | .statusLine = {
    "type": "command",
    "command": "bunx -y ccstatusline@latest",
    "padding": 0
  }
' "$tmp_input" >"$tmp_output"

if [[ -f "$settings_file" ]] && cmp -s "$tmp_output" "$settings_file"; then
  exit 0
fi

install -m 600 "$tmp_output" "$settings_file"
exit 2
