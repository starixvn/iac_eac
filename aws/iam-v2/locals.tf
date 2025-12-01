locals {
  project     = var.project
  environment = var.environment
  team        = var.team
  dept        = var.dept
  common_tags = {
    Dept         = local.dept
    Team         = local.team
    ManageBy     = "vnTerraform"
    Environment  = upper(local.environment)
    map-migrated = "migQK0IMQ5LFK"
  }
}
