
output "role_ids" {
  value = {
    for k, name in module.approle-v1 : k => name.role_id
  }
}
output "secret_ids" {
  sensitive = true
  value = {
    for k, name in module.approle-v1 : k => name.secret_id
  }
}
/*
output "pipeline_auth_role" {
  description = "The role name of the Vault JWT auth backend for pipeline"
  value       = vault_jwt_auth_backend_role.pipeline.role_name
}

output "role_ids" {
  #sensitive = "true"
  value = {
    for k, bd in vault_approle_auth_backend_role.entity-role : bd.role_name => bd.role_id
  }
}

output "secret_ids" {
  sensitive = "true"
  value = {
    for k, bd in vault_approle_auth_backend_role_secret_id.entity-role-secret-id : bd.role_name => bd.secret_id
  }
}

#################### Automation & Tools
output "prometheus_token" {
  description = "prometheus_token"
  sensitive   = true
  value       = vault_token.prometheus_token
}

###################
output "vault_identity_entity" {
  description = "vault_identity_entity"
  value = {
    for team, username in vault_identity_entity.vault_entities : username.name => username.id
  }
}

output "env_group_admin_id" {
  value       = module.env_policies.env_group_admin_id
  description = "The group ID of read/write create/delete policy"
}

output "env_group_readonly_id" {
  value       = module.env_policies.env_group_readonly_id
  description = "The group ID of readonly policy"
}
*/