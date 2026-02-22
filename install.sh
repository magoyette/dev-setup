#!/bin/bash
set -euo pipefail

# Change to the repo root regardless of where the script is called from
cd "$(dirname "$0")"

if [ ! -f ansible/vars.yml ]; then
  cp ansible/vars.yml.example ansible/vars.yml
  echo "Created ansible/vars.yml from vars.yml.example"
  echo "Edit ansible/vars.yml with your values before continuing."
  exit 1
fi

echo "Installing Ansible"
sudo apt update
sudo apt install -y ansible

echo "Installing Ansible collections"
ansible-galaxy collection install -r ansible/requirements.yml

echo "Running Ansible playbook"
ansible-playbook --ask-become-pass ansible/playbook.yml
