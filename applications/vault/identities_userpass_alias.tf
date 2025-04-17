## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity_alias
resource "vault_identity_entity_alias" "userpass_alias" {
  for_each             = { for user in local.vault_users_config : user.username => user }
  name           = each.value.username
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.vault_entities[each.value.username].id
}
resource "vault_identity_entity_alias" "userpass_alias_readonly" {
  for_each             = { for user in local.vault_users_readonly_config : user.username => user }
  name           = each.value.username
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.vault_entities_readonly[each.value.username].id
}

data "vault_auth_backend" "token_auth_backend" {
  path = "token"
}

resource "vault_identity_entity_alias" "token_alias" {
  for_each             = { for user in local.vault_users_config : user.username => user }
  name           = each.value.username
  mount_accessor = data.vault_auth_backend.token_auth_backend.accessor
  canonical_id   = vault_identity_entity.vault_entities[each.value.username].id
}

resource "vault_identity_entity_alias" "token_alias_readonly" {
  for_each             = { for user in local.vault_users_readonly_config : user.username => user }
  name           = each.value.username
  mount_accessor = data.vault_auth_backend.token_auth_backend.accessor
  canonical_id   = vault_identity_entity.vault_entities_readonly[each.value.username].id
}