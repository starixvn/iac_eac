### https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group_member_entity_ids
resource "vault_identity_group_member_entity_ids" "vault_admin" {
  exclusive         = false
  for_each          = { for user in local.vault_users_config : user.username => user }
  member_entity_ids = [vault_identity_entity.vault_entities[each.value.username].id]
  group_id          = module.env_policies.env_group_admin_id["${each.value.team}"]
}

resource "vault_identity_group_member_entity_ids" "vault_readonly" {
  exclusive         = false
  for_each          = { for user in local.vault_users_readonly_config : user.username => user }
  member_entity_ids = [vault_identity_entity.vault_entities_readonly[each.value.username].id]
  group_id          = module.env_policies.env_group_readonly_id["${each.value.team}"]
}
