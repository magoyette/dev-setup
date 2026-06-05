#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-$HOME/.crit.config.json}"
config_dir="$(dirname "$config_file")"
tmp_input="$(mktemp)"
tmp_output="$(mktemp)"

trap 'rm -f "$tmp_input" "$tmp_output"' EXIT

mkdir -p "$config_dir"

if [[ -f "$config_file" ]]; then
  if ! jq -e . "$config_file" >/dev/null 2>&1; then
    echo "Error: invalid JSON in $config_file" >&2
    exit 1
  fi
  cp "$config_file" "$tmp_input"
else
  printf '{}\n' >"$tmp_input"
fi

jq '.share_url = ""' "$tmp_input" >"$tmp_output"

if [[ -f "$config_file" ]] && cmp -s "$tmp_output" "$config_file"; then
  exit 0
fi

install -m 600 "$tmp_output" "$config_file"
exit 2
