#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
hooks_dir="${repo_root}/.githooks"
pre_commit_hook="${hooks_dir}/pre-commit"

if [[ ! -f "${pre_commit_hook}" ]]; then
  echo "Error: missing ${pre_commit_hook}" >&2
  exit 1
fi

chmod +x "${pre_commit_hook}"
chmod +x "${repo_root}/scripts/sync-agent-docs.sh" "${repo_root}/scripts/check-agent-docs.sh"

git -C "${repo_root}" config core.hooksPath .githooks

echo "Installed local git hooks via core.hooksPath=.githooks"
