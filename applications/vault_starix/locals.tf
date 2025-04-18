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
      bound_cidrs     = try(role.bound_cidrs, var.CIDR_OFFICE)
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

  kube_auth_backend_roles = flatten([
    for backend in var.kube_auth_backends : length(backend) == 0 ? [] : [
      for role in backend.roles : {
        backend_path = backend.path
        role_name    = role.role_name
        sa_name      = role.sa_name
        sa_namespace = role.sa_namespace
        policies     = role.policies
      }
    ]
  ])

  aws_authz_backend_roles = flatten([
    for backend in var.aws_secret_backend : length(backend) == 0 ? [] : [
      for role in backend.roles : {
        backend         = backend.backend
        name            = role.name
        credential_type = role.credential_type
        role_arns       = backend.backend == "aws_local" ? [var.application_aws_assume_role, ] : [var.application_aws_assume_role, ]
        policy_document = role.policy_document_file
      }
    ]
  ])
}
