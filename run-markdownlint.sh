#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v markdownlint-cli2 >/dev/null 2>&1; then
  echo "Error: markdownlint-cli2 is not installed. Re-run the node playbook first." >&2
  exit 1
fi

cd "${repo_root}"

exec markdownlint-cli2 \
  '**/*.md' \
  '#claude/.claude' \
  '#external-skills' \
  '#external-skills-claude' \
  '#external-skills-codex' \
  '#skills' \
  '#skills-claude' \
  '#skills-codex'
