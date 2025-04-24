### Define Local Values in Terraform
locals {
  ## Define 
  policies_config = flatten([
    for policy in var.polices : {
      policy_name     = policy.policy_name
      policy_path     = policy.policy_path
      policy_template = policy.policy_template
    }
  ])

  roles_config = flatten([
    for role in var.roles : {
      role_name       = role.role_name
      policy_path     = role.policy_path
      policy_template = role.policy_template
    }
  ])

  vault_mount_config = flatten([
    for mount in var.vault_mount : {
      mount_type = mount.type
      mount_path = mount.path
    }
  ])

  vault_generic_secret_config = flatten([
    for vault_generic in var.vault_generic_secret : {
      username = vault_generic.username
      password = vault_generic.password
      path     = vault_generic.path
    }
  ])
  ###AUTH
  vault_users_config = flatten([
    for auth in var.vault_users : {
      username = auth.name
      team     = auth.team
    }
  ])

  vault_users_readonly_config = flatten([
    for auth_readonly in var.vault_users_readonly : {
      username = auth_readonly.name
      team     = auth_readonly.team
    }
  ])

  vault_kubernetes_auth_role = flatten([
    for auth_role in var.kubernetes_auth_role : {
      role_name    = auth_role.role_name
      sa_name      = auth_role.sa_name
      sa_namespace = auth_role.sa_namespace
      policies     = auth_role.policies
    }
  ])

}
