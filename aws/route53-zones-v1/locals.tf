locals {
  project     = var.project
  environment = var.environment
  team        = var.team
  common_tags = {
    Dept        = "VNTeam"
    Team        = local.team
    ManageBy    = "vnTerraform"
    Environment = local.environment
  }
}

locals {
  domain_zone_config = flatten([
    for domain in var.domain_zones : {
      domain = domain
    }
  ]
  )
}

