## 
## Create vault Users
##
## https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_entity
resource "vault_identity_entity" "vault_entities" {
  for_each             = { for user in local.vault_users_config : user.username => user }
  name     = each.value.username
}

resource "vault_identity_entity" "vault_entities_readonly" {
  for_each             = { for user in local.vault_users_readonly_config : user.username => user }
  name     = each.value.username
}

# Create approle entities
resource "vault_identity_entity" "entity" {
  for_each = { for role in local.roles_config : role.role_name => role }
  name     = each.value.role_name
  policies = [each.value.role_name]
}

# Create approle alias
resource "vault_identity_entity_alias" "entity_alias" {
  for_each       = { for role in local.roles_config : role.role_name => role }
  name           = module.approle-v1[each.value.role_name].role_name
  mount_accessor = data.vault_auth_backend.this.accessor
  canonical_id   = vault_identity_entity.entity[each.value.role_name].id
}