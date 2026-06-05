#!/usr/bin/env bash
set -euo pipefail

repo="tomasz-tomczyk/crit"
asset_name="crit-linux-amd64"
bin="$HOME/.local/bin/crit-bin"
api_url="https://api.github.com/repos/${repo}/releases/latest"

latest_json="$(curl -fsSL "$api_url")"
latest_version="$(jq -r '.tag_name // empty' <<<"$latest_json")"

if [[ -z "$latest_version" || "$latest_version" == "null" ]]; then
  echo "crit: could not resolve latest version" >&2
  exit 1
fi

current_version=""
if [[ -x "$bin" ]]; then
  current_version="$("$bin" --version 2>/dev/null | sed -nE 's/.*(v?[0-9]+[.][0-9]+[.][0-9]+).*/\1/p' | head -n 1 || true)"
fi

if [[ "${current_version#v}" == "${latest_version#v}" ]]; then
  exit 0
fi

asset_url="$(jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url' <<<"$latest_json")"
checksums_url="$(jq -r '.assets[] | select(.name == "checksums.txt") | .browser_download_url' <<<"$latest_json")"

if [[ -z "$asset_url" || "$asset_url" == "null" || -z "$checksums_url" || "$checksums_url" == "null" ]]; then
  echo "crit: latest release is missing expected assets" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "$asset_url" -o "$tmp_dir/$asset_name"
curl -fsSL "$checksums_url" -o "$tmp_dir/checksums.txt"

expected_sha="$(awk -v name="$asset_name" '$2 == name {print $1}' "$tmp_dir/checksums.txt")"
if [[ -z "$expected_sha" ]]; then
  echo "crit: checksum not found for $asset_name" >&2
  exit 1
fi

printf '%s  %s\n' "$expected_sha" "$tmp_dir/$asset_name" | sha256sum --check --status
install -m 0755 "$tmp_dir/$asset_name" "$bin"
