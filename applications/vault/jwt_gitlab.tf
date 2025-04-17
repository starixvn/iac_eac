// INIT THE VAULT
resource "vault_jwt_auth_backend" "gitlab" {
  description            = "JWT auth backend for Gitlab-CI pipeline"
  path                   = "jwt"
  bound_issuer           = var.gitlab_domain
  jwt_validation_pubkeys = var.jwk_gitlab_nexdev
  # jwks_url     = "https://${var.gitlab_domain}/-/jwks"
  # default_role = "default"

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
  backend         = vault_jwt_auth_backend.gitlab.path
  role_type       = "jwt"
  role_name       = "vault_jwt_auth_backend-pipeline"
  token_policies  = ["terraform"]
  bound_audiences = [var.gitlab_domain]
  bound_claims = {
    project_id = var.gitlab_project_id
    ref        = "main,testlab,dev,local,uat,prod,kldr,sit"
    ref_type   = "branch"
  }
  user_claim             = "user_email"
  token_explicit_max_ttl = var.jwt_token_max_ttl
}


#################################################
resource "vault_aws_secret_backend_role" "pipeline" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "vault-aws-assumed-role"
  credential_type = "assumed_role"

  role_arns = [var.application_aws_assume_role]

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*", "rds:*", "s3:*", "dynamodb:*", "iam:*", "ssm:*", "elasticloadbalancing:*", "kms:*", "logs:*", "eks:*", "autoscaling:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetUser"
      ],
      "Resource": "arn:aws:iam::*:user/$${aws:username}"
    }
  ]
}
EOF
}

// PIPELINE
data "vault_policy_document" "pipeline_aws_read" {
  rule {
    required_parameters = []
    path                = "${vault_aws_secret_backend.aws.path}/sts/${vault_aws_secret_backend_role.pipeline.name}"
    capabilities        = ["read", "update", "create"]
    description         = "Allow to read AWS secrets"
  }
  rule {
    required_parameters = []
    path                = "auth/${vault_auth_backend.aws.path}/*"
    capabilities        = ["read", "update", "create", "delete", "list"]
    description         = "Allow to manage authentification into the Vault with AWS auth method"
  }
  rule {
    required_parameters = []
    path                = "auth/token/create"
    capabilities        = ["update"]
    description         = "Allow pipeline to create a Vault child token when using Terraform"
  }
}

resource "vault_policy" "pipeline" {
  name   = "gitlab-aws-ci"
  policy = data.vault_policy_document.pipeline_aws_read.hcl
}
resource "vault_jwt_auth_backend_role" "jwt_auth_backend_pipeline_v1" {
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name      = "gitlab-aws-auth-ci"
  token_policies = ["default", vault_policy.pipeline.name]

  bound_claims = {
    project_id = 2625
    ref        = "main,testlab,local,uat"
    ref_type   = "branch"
  }
  user_claim             = "user_email"
  token_explicit_max_ttl = var.jwt_token_max_ttl
}
