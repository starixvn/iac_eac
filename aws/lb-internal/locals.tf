# Define Local Values in Terraform
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

locals {
  # Define Proxy GW
  proxy_gw_serverconfig = [
    for srv in var.proxy_gw_vm : {
      instance_name = "${srv.application_name}" #-${i}
      private_ip    = srv.private_ip
    }
  ]
  # Define Mon
  mons_serverconfig = [
    for srv in var.mon_server_configuration : {
      instance_name = "${srv.application_name}" #-${i}
      private_ip    = srv.private_ip
    }
  ]
  # Define App
  apps_serverconfig = [
    for srv in var.web_server_configuration : {
      instance_name = "${srv.application_name}" #-${i}
      private_ip    = srv.private_ip
    }
  ]
  # Define Tools
  ansible_serverconfig = [
    for srv in var.ansible_server_configuration : {
      instance_name = "${srv.application_name}"
      private_ip    = srv.private_ip
    }
  ]

  registry_serverconfig = [
    for srv in var.registry_server_configuration : {
      instance_name = "${srv.application_name}"
      private_ip    = srv.private_ip
    }
  ]
}
// We need to Flatten it before using it
locals {
  proxy_gw_instances = flatten(local.proxy_gw_serverconfig)
  mons_instances     = flatten(local.mons_serverconfig)
  apps_instances     = flatten(local.apps_serverconfig)
  ansible_instances     = flatten(local.ansible_serverconfig)
  registry_instances     = flatten(local.registry_serverconfig)
}
