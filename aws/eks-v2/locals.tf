# Define Local Values in Terraform
locals {
  project     = var.project
  environment = var.environment
  team        = var.team
  common_tags = {
    Dept        = "VNTeam"
    Team        = local.team
    ManageBy    = "vnTerraform"
    Environment = upper(local.environment)
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