#!/bin/bash
set -eo pipefail

echo "🔍 Validating Terraform configuration in ${CI_PROJECT_DIR}"
cd ${TF_ROOT}

# Initialize Terraform
terraform init -backend-config="environments/${ENVIRONMENT}/backend.hcl"

# Validate and format check
terraform validate
terraform fmt -check -recursive

# Security scanning with tfsec
#docker run --rm -v $(pwd):/src -w /src aquasec/tfsec:latest /src

# Policy checking with OPA
if [ -d "policy" ]; then
  terraform plan -out=tfplan.binary
  terraform show -json tfplan.binary > tfplan.json
  docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy /project/policy /project/tfplan.json
fi