#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-$HOME/.claude.json}"
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

mcp_catalog="${AI_ASSISTANTS_MCP_CATALOG:-}"
enabled_mcps="${AI_ASSISTANTS_MCPS:-[]}"

if [[ -z "$mcp_catalog" ]]; then
  mcp_catalog='{}'
fi

jq --argjson catalog "$mcp_catalog" --argjson enabled "$enabled_mcps" '
  def managed_names: $catalog | keys;
  def enabled_servers:
    reduce $enabled[] as $name ({};
      .[$name] = {
        "type": "http",
        "url": $catalog[$name].url
      }
    );

  .mcpServers = (
    ((.mcpServers // {}) | with_entries(select(.key as $key | managed_names | index($key) | not)))
    + enabled_servers
  )
' "$tmp_input" >"$tmp_output"

if [[ -f "$config_file" ]] && cmp -s "$tmp_output" "$config_file"; then
  exit 0
fi

install -m 600 "$tmp_output" "$config_file"
exit 2
