#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-$HOME/.codex/config.toml}"
profile_file="${2:-$HOME/.codex/superpowers.config.toml}"
section='plugins."superpowers@dev-setup-superpowers"'
tmp_dir="$(mktemp -d)"
tmp_file="$tmp_dir/config"

trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$(dirname "$config_file")"
touch "$config_file"

awk -v section="$section" '
  $0 == "[" section "]" {
    skip = 1
    next
  }
  skip && /^\[/ {
    skip = 0
  }
  !skip {
    print
  }
' "$config_file" >"$tmp_file"

while [[ -s "$tmp_file" ]] && [[ -z "$(tail -n 1 "$tmp_file")" ]]; do
  sed -i '$d' "$tmp_file"
done

{
  cat "$tmp_file"
  if [[ -s "$tmp_file" ]]; then
    printf '\n'
  fi
  printf '[%s]\n' "$section"
  printf 'enabled = false\n'
} >"$tmp_dir/base"

cat >"$tmp_dir/profile" <<EOF
[$section]
enabled = true
EOF

changed=false
if ! cmp -s "$tmp_dir/base" "$config_file" || [[ "$(stat -c %a "$config_file")" != 644 ]]; then
  install -m 0644 "$tmp_dir/base" "$config_file"
  changed=true
fi

if [[ ! -f "$profile_file" ]] || ! cmp -s "$tmp_dir/profile" "$profile_file" || [[ "$(stat -c %a "$profile_file")" != 644 ]]; then
  install -m 0644 "$tmp_dir/profile" "$profile_file"
  changed=true
fi

if [[ "$changed" == true ]]; then
  exit 2
fi
