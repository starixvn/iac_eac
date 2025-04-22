
/*** DEV ENV ***/
## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group
resource "vault_identity_group" "env_admin" {
  for_each          = toset(var.vault_team)
  name                       = "${each.key}/admin"
  type                       = "internal"
  policies                   = ["${each.key}/admin"]
  external_member_entity_ids = true
}


## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group
resource "vault_identity_group" "env_readonly" {
  for_each          = toset(var.vault_team)
  name                       = "${each.key}/readonly"
  type                       = "internal"
  policies                   = ["${each.key}/readonly"]
  external_member_entity_ids = true
}
