#!/usr/bin/env python3
"""
Validate Terraform outputs structure
"""
import json
import sys

def validate_outputs():
    required_outputs = [
        "vault_endpoint",
        "k8s_cluster_name",
        "storage_bucket"
    ]
    
    try:
        with open("tf_outputs.json") as f:
            data = json.load(f)
            
        missing = [o for o in required_outputs if o not in data]
        if missing:
            raise KeyError(f"Missing outputs: {missing}")
            
        # Type validation
        if not data["vault_endpoint"].startswith("https://"):
            raise ValueError("Invalid Vault endpoint format")
            
        return True
    except Exception as e:
        print(f"Validation failed: {str(e)}", file=sys.stderr)
        return False

if __name__ == "__main__":
    if validate_outputs():
        print("✓ Terraform outputs validated")
        sys.exit(0)
    else:
        sys.exit(1)