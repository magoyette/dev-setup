#!/usr/bin/env bash
set -euo pipefail

plugin_id="superpowers-crit@dev-setup-superpowers"
refresh="${SUPERPOWERS_CRIT_REFRESH:-false}"

catalog="$(codex plugin list --available --json)"
installed_version="$(jq -r --arg id "$plugin_id" '.installed[] | select(.pluginId == $id) | .version' <<<"$catalog")"

if [[ -n "$installed_version" ]] && [[ "$refresh" != true ]]; then
  exit 0
fi

if [[ -n "$installed_version" ]]; then
  codex plugin remove "$plugin_id" --json >/dev/null
fi

codex plugin add "$plugin_id" --json >/dev/null
exit 2
