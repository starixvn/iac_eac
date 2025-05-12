locals {
  project     = var.project
  environment = var.environment
  team        = var.team
  common_tags = {
    Dept         = "VNTeam"
    Team         = local.team
    ManageBy     = "vnTerraform"
    Environment  = upper(local.environment)
    map-migrated = "migQK0IMQ5LFK"
  }
}
