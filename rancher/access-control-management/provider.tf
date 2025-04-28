terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~>6.0"
    }
  }
  backend "s3" {}
}

provider "rancher2" {
  api_url   = var.rancher-url[var.cluster_org][var.cluster_env]
  token_key = var.rancher-token[var.cluster_org][var.cluster_env]
}
