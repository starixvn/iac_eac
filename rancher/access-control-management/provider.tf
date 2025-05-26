terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~>6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.8.0"
    }
  }
  backend "s3" {}
}

provider "rancher2" {
  api_url   = var.rancher-url[var.cluster_org][var.cluster_env]
  token_key = data.vault_kv_secret_v2.secrets["rancher_cred"].data["token_key"]
}
