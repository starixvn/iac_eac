
# Create Policies in the root namespace
resource "vault_policy" "policy_v1" {
  for_each = { for policy in local.policies_config : policy.policy_name => policy }
  name     = each.value.policy_name
  policy   = file("policies/${each.value.policy_path}/${each.value.policy_template}.hcl")
}

################### Role
module "approle-v1" {
  source           = "git::https://gitlab.nexdev.net/iac/terraform/modules/vault-approle-terraform.git//src"
  for_each         = { for role in local.roles_config : role.role_name => role }
  role_name        = each.value.role_name
  token_period     = 3600
  create_secret_id = "true"
  policy_name      = each.value.role_name
  policy           = file("policies/${each.value.policy_path}/${each.value.policy_template}.hcl")
}

###########################################
data "vault_auth_backend" "this" {
  path = "approle"
}
