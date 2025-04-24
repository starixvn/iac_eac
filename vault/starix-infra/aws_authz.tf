#################################################
resource "vault_aws_secret_backend_role" "role" {
  depends_on = [vault_aws_secret_backend.aws]
  for_each   = { for idx, role in local.aws_authz_backend_roles : idx => role }

  backend         = each.value.backend
  name            = each.value.name
  credential_type = each.value.credential_type
  role_arns       = each.value.role_arns
  policy_document = file("policies/aws-authz/${each.value.policy_document}")
}
