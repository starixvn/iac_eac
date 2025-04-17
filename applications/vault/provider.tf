terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>3.0"
    }
  }
  backend "s3" {
  }
}
####
provider "vault" {
  address          = var.vault_address
  skip_child_token = true #https://stackoverflow.com/questions/73034161/permission-denied-on-vault-terraform-provider-token-creation

  # auth_login {
  #   path = "auth/approle/login"
  #   parameters = {
  #     role_id   = ""
  #     secret_id = ""
  #   }
  # }
}
