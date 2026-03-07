#!/bin/bash
set -euo pipefail

# Change to the repo root regardless of where the script is called from
cd "$(dirname "$0")"

if [ ! -f ansible/vars.yml ]; then
  cp ansible/vars.yml.example ansible/vars.yml
  echo "Created ansible/vars.yml from vars.yml.example"
  echo "Edit ansible/vars.yml with your git_user_name and git_user_email before continuing."
  exit 1
fi

PLAYBOOK="ansible/${1:-playbook}.yml"

# Prompt for sudo password and validate it before starting the playbook
# to avoid the playbook hanging indefinitely on an incorrect password
read -rsp "BECOME password: " become_pass
echo >&2

if ! printf '%s\n' "$become_pass" | timeout 5 sudo -S true 2>/dev/null; then
  echo "Error: incorrect sudo password" >&2
  exit 1
fi

echo "Installing Ansible"
printf '%s\n' "$become_pass" | sudo -S apt update
printf '%s\n' "$become_pass" | sudo -S apt install -y ansible

echo "Installing Ansible collections"
ansible-galaxy collection install -r ansible/requirements.yml

echo "Running Ansible playbook: ${PLAYBOOK}"
ANSIBLE_BECOME_PASS="$become_pass" ansible-playbook "${PLAYBOOK}"
