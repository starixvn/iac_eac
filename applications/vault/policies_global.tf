## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "backup_policy" {
  name   = "global/backup"
  policy = file("${path.module}/policies/tools/backup.hcl")
}

## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "automated-token-renew" {
  name   = "global/automated-token-renew"
  policy = file("${path.module}/policies/tools/automated-token-renew.hcl")
}

## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "user-management" {
  name   = "global/user-management"
  policy = file("${path.module}/policies/tools/user-management.hcl")
}

## SelfService Password Reset
resource "vault_policy" "user-selfservice-password-reset" {
  name   = "global/user-selfservice-password-reset"
  policy = file("${path.module}/policies/vault-admin/user-selfservice-password-reset.hcl")
}

## Vault Policy Readonly Role
resource "vault_policy" "global-pontus-policy-admin" {
  name   = "global/pontus-policy-admin"
  policy = file("${path.module}/policies/vault-admin/pontus-policy-admin.hcl")
}


## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "vault-admin" {
  name   = "global/vault-admin"
  policy = file("${path.module}/policies/tools/vault-admin.hcl")
}



## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "pki_team_policy" {
  name   = "global/pki-team"
  policy = file("${path.module}/policies/tools/pki-team.hcl")
}


## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "oidc_token_create" {
  name   = "global/oidc-token"
  policy = <<EOT

## Allow user self-service MFA
path "identity/oidc/token/role" {
  capabilities = [  "read"]
}
EOT
}


## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "transit_admin" {
  name   = "${vault_mount.transit.path}/admin"
  policy = <<EOT

# Enable transit secrets engine
path "sys/mounts/${vault_mount.transit.path}" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# To read enabled secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Manage the transit secrets engine
path "${vault_mount.transit.path}/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
EOT
}


## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "transit_operator" {
  name   = "${vault_mount.transit.path}/operator"
  policy = <<EOT

# Manage the transit secrets engine
path "${vault_mount.transit.path}/keys" {
  capabilities = [  "read","list" ]
}
EOT
}
