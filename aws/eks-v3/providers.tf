terraform {
  required_version = ">= 1.4"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
      #version = "4.65.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

# Datasource: AWS Caller Identity
data "aws_caller_identity" "current" {} # used for accesing Account ID and ARN

provider "aws" {
  region = var.aws_region
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
  }
}
