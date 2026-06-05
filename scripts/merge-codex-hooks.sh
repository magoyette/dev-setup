#!/usr/bin/env bash
set -euo pipefail

hooks_file="${1:-$HOME/.codex/hooks.json}"
hooks_dir="$(dirname "$hooks_file")"
tmp_input="$(mktemp)"
tmp_output="$(mktemp)"

trap 'rm -f "$tmp_input" "$tmp_output"' EXIT

mkdir -p "$hooks_dir"

if [[ -f "$hooks_file" ]]; then
  if ! jq -e . "$hooks_file" >/dev/null 2>&1; then
    echo "Error: invalid JSON in $hooks_file" >&2
    exit 1
  fi
  cp "$hooks_file" "$tmp_input"
else
  printf '{}\n' >"$tmp_input"
fi

jq '
  def notify_command:
    "bash \"$HOME/.codex/hooks/wsl-notify.sh\"";

  def validate_command:
    "bash \"$HOME/.codex/hooks/validate-edited-files.sh\"";

  def has_managed_command($command):
    (.hooks // []) | any(.command? == $command);

  def without_managed($command):
    map(select((has_managed_command($command)) | not));

  def permission_request_hook:
    {
      "matcher": "*",
      "hooks": [
        {
          "type": "command",
          "command": notify_command,
          "timeout": 5
        }
      ]
    };

  def stop_hook:
    {
      "hooks": [
        {
          "type": "command",
          "command": notify_command,
          "timeout": 5
        }
      ]
    };

  def post_tool_use_hook:
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": validate_command,
          "timeout": 120,
          "statusMessage": "Validating edited files"
        }
      ]
    };

  .hooks = ((.hooks // {}) as $hooks | $hooks * {
    "PermissionRequest": (
      (($hooks.PermissionRequest // []) | without_managed(notify_command))
      + [permission_request_hook]
    ),
    "Stop": (
      (($hooks.Stop // []) | without_managed(notify_command))
      + [stop_hook]
    ),
    "PostToolUse": (
      (($hooks.PostToolUse // []) | without_managed(validate_command))
      + [post_tool_use_hook]
    )
  })
' "$tmp_input" >"$tmp_output"

if [[ ! -L "$hooks_file" && -f "$hooks_file" ]] && cmp -s "$tmp_output" "$hooks_file"; then
  exit 0
fi

if [[ -L "$hooks_file" ]]; then
  rm "$hooks_file"
fi

install -m 600 "$tmp_output" "$hooks_file"
exit 2
