#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-$HOME/.codex/config.toml}"
config_dir="$(dirname "$config_file")"
tmp_input="$(mktemp)"
tmp_output="$(mktemp)"
tmp_unmanaged="$(mktemp)"

trap 'rm -f "$tmp_input" "$tmp_output" "$tmp_unmanaged"' EXIT

mkdir -p "$config_dir"

if [[ -f "$config_file" ]]; then
  cp "$config_file" "$tmp_input"
else
  : >"$tmp_input"
fi

mcp_catalog="${AI_ASSISTANTS_MCP_CATALOG:-}"
enabled_mcps="${AI_ASSISTANTS_MCPS:-[]}"

if [[ -z "$mcp_catalog" ]]; then
  mcp_catalog='{}'
fi

managed_pattern="$(jq -r 'keys | map(gsub("[][.^$*+?(){}|\\\\]"; "\\\\&")) | join("|")' <<<"$mcp_catalog")"

awk -v managed_pattern="$managed_pattern" '
  /^\[/ {
    header = $0
    sub(/^\[/, "", header)
    sub(/\]$/, "", header)
    skip = managed_pattern != "" && header ~ "^mcp_servers\\.(" managed_pattern ")(\\.|$)"
  }
  !skip { print }
' "$tmp_input" >"$tmp_unmanaged"

awk '
  { lines[NR] = $0 }
  END {
    end = NR
    while (end > 0 && lines[end] ~ /^[[:space:]]*$/) {
      end--
    }
    for (line = 1; line <= end; line++) {
      print lines[line]
    }
  }
' "$tmp_unmanaged" >"$tmp_output"

while IFS= read -r name; do
  url="$(jq -r --arg name "$name" '.[$name].url' <<<"$mcp_catalog")"
  if [[ -s "$tmp_output" ]]; then
    printf '\n' >>"$tmp_output"
  fi
  printf '[mcp_servers.%s]\nurl = "%s"\n' "$name" "$url" >>"$tmp_output"
done < <(jq -r --argjson enabled "$enabled_mcps" '$enabled[]' <<<"$mcp_catalog")

if [[ -f "$config_file" ]] && cmp -s "$tmp_output" "$config_file"; then
  exit 0
fi

install -m 600 "$tmp_output" "$config_file"
exit 2
