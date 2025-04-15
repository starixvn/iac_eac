#!/bin/sh
# Mock Terraform operations in demo mode
[ "$DEMO_MODE" = "true" ] && {
  echo "{\"vault_endpoint\":\"https://vault-test.example.com\"}" > tf_outputs.json
  exit 0
}

# Real execution
terraform init && terraform validate