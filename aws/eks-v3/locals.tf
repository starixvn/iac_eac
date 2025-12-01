# Define Local Values in Terraform
locals {
  project     = var.project
  environment = var.environment
  team        = var.team
  dept        = var.dept
  aws_region  = var.aws_region
  common_tags = {
    Dept         = local.dept
    Team         = local.team
    ManageBy     = "vnTerraform"
    Environment  = upper(local.environment)
    Region       = local.aws_region
    map-migrated = "migQK0IMQ5LFK"
  }
}

locals {
  cluster_name = lower("${var.team}-${var.environment}-eks") #-${random_string.suffix.result}
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}