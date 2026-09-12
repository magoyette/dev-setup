#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  printf 'usage: remove-codex-config-sections.sh <config-file> <section> [section...]\n' >&2
  exit 64
fi

config_file="$1"
shift

if [[ ! -f "$config_file" ]]; then
  exit 0
fi

target_found=false
while IFS= read -r line || [[ -n "$line" ]]; do
  for section in "$@"; do
    if [[ "$line" == "[$section]" ]]; then
      target_found=true
      break 2
    fi
  done
done <"$config_file"

if [[ "$target_found" == false ]]; then
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

printf '%s\n' "$@" >"$tmp_dir/sections"

awk '
  NR == FNR {
    sections["[" $0 "]"] = 1
    next
  }
  $0 in sections {
    skip = 1
    next
  }
  skip && /^\[/ {
    skip = 0
  }
  !skip {
    print
  }
' "$tmp_dir/sections" "$config_file" >"$tmp_dir/config"

if cmp -s "$tmp_dir/config" "$config_file"; then
  exit 0
fi

install -m "$(stat -c %a "$config_file")" "$tmp_dir/config" "$config_file"
exit 2
