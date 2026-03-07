#!/bin/bash
set -euo pipefail

# Change to the repo root regardless of where the script is called from
cd "$(dirname "$0")"

PLAYBOOK="ansible/${1:-playbook}.yml"

# Prompt for sudo password and validate it before starting the playbook
# to avoid the playbook hanging indefinitely on an incorrect password
read -rsp "BECOME password: " become_pass
echo >&2

if ! printf '%s\n' "$become_pass" | timeout 5 sudo -S true 2>/dev/null; then
  echo "Error: incorrect sudo password" >&2
  exit 1
fi

ANSIBLE_BECOME_PASS="$become_pass" ansible-playbook "${PLAYBOOK}"
