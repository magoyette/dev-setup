#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
actual_file="${repo_root}/AGENTS.md"
expected_file="$(mktemp)"
trap 'rm -f "${expected_file}"' EXIT

if [[ ! -f "${actual_file}" ]]; then
  echo "Error: missing ${actual_file}" >&2
  echo "Run: ./scripts/sync-agent-docs.sh" >&2
  exit 1
fi

"${repo_root}/scripts/sync-agent-docs.sh" --stdout > "${expected_file}"

if ! cmp -s "${actual_file}" "${expected_file}"; then
  echo "Error: AGENTS.md is out of sync with CLAUDE.md." >&2
  if command -v delta >/dev/null 2>&1; then
    echo "Showing diff with delta:" >&2
    diff -u \
      --label "AGENTS.md (current)" \
      --label "AGENTS.md (expected from CLAUDE.md)" \
      "${actual_file}" \
      "${expected_file}" \
      | delta --paging=never >&2 || true
  else
    echo "delta not found in PATH; showing unified diff:" >&2
    diff -u \
      --label "AGENTS.md (current)" \
      --label "AGENTS.md (expected from CLAUDE.md)" \
      "${actual_file}" \
      "${expected_file}" >&2 || true
  fi
  echo "Run: ./scripts/sync-agent-docs.sh" >&2
  exit 1
fi

echo "AGENTS.md is in sync with CLAUDE.md."
