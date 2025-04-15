#!/bin/bash
set -eo pipefail

echo "🔍 Linting Ansible playbooks and roles"
cd ${CI_PROJECT_DIR}

# Lint all Ansible content
ansible-lint --exclude=galaxy-roles/ ansible/

# Validate inventory files
for cluster in $(ls ansible/kubespray); do
  ansible-inventory -i ansible/kubespray/${cluster}/inventory.ini --list > /dev/null
done

# Validate vars files
yamllint ansible/kubespray/*/group_vars/
yamllint ansible/kubespray/*/host_vars/