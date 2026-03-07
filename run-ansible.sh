#!/bin/bash
set -euo pipefail

# Change to the repo root regardless of where the script is called from
cd "$(dirname "$0")"

PLAYBOOK="ansible/${1:-playbook}.yml"

ansible-playbook --ask-become-pass "${PLAYBOOK}"
