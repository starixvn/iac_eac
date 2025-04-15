#!/bin/bash
set -eo pipefail

echo "🚀 Deploying Terraform configuration for ${APP} in ${ENVIRONMENT}"
cd ${TF_ROOT}

# Initialize Terraform
terraform init -backend-config="environments/${ENVIRONMENT}/backend.hcl"

# Apply changes
if [ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ] || [ -n "$CI_COMMIT_TAG" ]; then
  terraform apply -auto-approve -input=false tfplan
  
  # Update outputs
  terraform output -json > outputs.json
  jq -c '.' outputs.json
  
  # Store state artifact
  terraform state pull > terraform.tfstate
else
  echo "Skipping deploy for non-default branch"
fi