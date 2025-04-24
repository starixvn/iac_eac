
## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "readonly" {
  for_each          = toset(var.vault_team)
  name   = "${each.key}/readonly"
  policy = <<EOT
## Allow to list metadata under secret/
## so that UI displays the list of base secret
## User will not be allow to deeper that one level
path "${each.key}/*" {
  capabilities = ["list", "read"]
}

EOT
}

## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy
resource "vault_policy" "admin" {
  for_each          = toset(var.vault_team)
  name   = "${each.key}/admin"
  policy = <<EOT


## Allow to list metadata under secret/
## so that UI displays the list of base secret
## User will not be allow to deeper that one level
path "${each.key}/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
    }
EOT
}