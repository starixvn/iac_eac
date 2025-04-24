resource "vault_auth_backend" "aws" {
  type        = "aws"
  path        = "aws_${var.env}"
}

resource "vault_aws_secret_backend" "aws" {
  description = "AWS ${var.env} secret engine for Gitlab-CI pipeline"
  path        = "aws_${var.env}"
  region      = var.region

  default_lease_ttl_seconds = var.aws_secret_default_ttl
  max_lease_ttl_seconds     = var.aws_secret_max_ttl
}