#!/bin/bash
set -euo pipefail

# Change to the repo root regardless of where the script is called from
cd "$(dirname "$0")"

ansible-playbook --ask-become-pass ansible/playbook.yml
