#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-$HOME/.config/hunk/config.toml}"
theme="${2:-one-dark-pro}"
config_dir="$(dirname "$config_file")"

if [[ ! "$theme" =~ ^[a-z0-9]+([-_][a-z0-9]+)*$ ]]; then
  printf 'Error: invalid Hunk theme identifier: %s\n' "$theme" >&2
  exit 1
fi

mkdir -p "$config_dir"
tmp_output="$(mktemp "${config_file}.tmp.XXXXXX")"
trap 'rm -f "$tmp_output"' EXIT

input_file="/dev/null"
if [[ -f "$config_file" ]]; then
  input_file="$config_file"
fi

top_level_theme_count="$(
  awk '
    /^[[:space:]]*\[/ { in_table = 1 }
    !in_table && /^[[:space:]]*theme[[:space:]]*=/ { count++ }
    END { print count + 0 }
  ' "$input_file"
)"

if ((top_level_theme_count > 1)); then
  printf 'Error: multiple top-level theme assignments in %s\n' "$config_file" >&2
  exit 1
fi

awk -v managed_theme="$theme" '
  function comment_suffix(line,    char, escaped, i, quote) {
    quote = ""
    escaped = 0

    for (i = 1; i <= length(line); i++) {
      char = substr(line, i, 1)

      if (quote == "\"") {
        if (escaped) {
          escaped = 0
        } else if (char == "\\") {
          escaped = 1
        } else if (char == "\"") {
          quote = ""
        }
      } else if (quote == "\047") {
        if (char == "\047") {
          quote = ""
        }
      } else if (char == "\"" || char == "\047") {
        quote = char
      } else if (char == "#") {
        return substr(line, i)
      }
    }

    return ""
  }

  /^[[:space:]]*\[/ && !in_table {
    if (!managed) {
      print "theme = \"" managed_theme "\""
    }
    in_table = 1
  }

  !in_table && /^[[:space:]]*theme[[:space:]]*=/ {
    suffix = comment_suffix($0)
    if (suffix != "") {
      print "theme = \"" managed_theme "\" " suffix
    } else {
      print "theme = \"" managed_theme "\""
    }
    managed = 1
    next
  }

  { print }

  END {
    if (!managed && !in_table) {
      print "theme = \"" managed_theme "\""
    }
  }
' "$input_file" >"$tmp_output"

if [[ -f "$config_file" ]] && cmp -s "$tmp_output" "$config_file" &&
  [[ "$(stat -c '%a' "$config_file")" == "600" ]]; then
  exit 0
fi

chmod 0600 "$tmp_output"
mv -f "$tmp_output" "$config_file"
exit 2
