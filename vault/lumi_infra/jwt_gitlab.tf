// INIT THE VAULT
resource "vault_jwt_auth_backend" "gitlab" {
  description  = "JWT auth backend for Gitlab-CI pipeline"
  path         = "jwt"
  jwks_url     = "https://${var.gitlab_domain}/-/jwks"
  bound_issuer = var.gitlab_domain
  default_role = "default"

  tune {
    default_lease_ttl = var.jwt_auth_tune_default_ttl
    max_lease_ttl     = var.jwt_auth_tune_max_ttl
    token_type        = "default-service"
  }
}

/*
resource "vault_policy" "pipeline" {
  name   = "vault_jwt_auth_backend-pipeline"
  policy = data.vault_policy_document.pipeline_aws_read.hcl
}
*/
resource "vault_jwt_auth_backend_role" "pipeline" {
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name      = "vault_jwt_auth_backend-pipeline"
  token_policies = ["terraform"]

  bound_claims = {
    project_id = var.gitlab_project_id
    ref        = "main,testlab,dev,local,uat"
    ref_type   = "branch"
  }
  user_claim             = "user_email"
  token_explicit_max_ttl = var.jwt_token_max_ttl
}
