output "env_group_admin_id" {
  #value       = vault_identity_group.env_admin.id
  description = "The group ID of read/write create/delete policy"
  value = {
    for k, name in vault_identity_group.env_admin : k => name.id
  }
}

output "env_group_readonly_id" {
  value = {
    for k, name in vault_identity_group.env_readonly : k => name.id
  }
  description = "The group ID of readonly policy"
}
