#### Define Local Values in Terraform
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

data "aws_ami" "os" {
  for_each = local.allowed_os

  most_recent = true
  owners      = [each.value.owner]
  filter {
    name   = "name"
    values = [each.value.filter]
  }
}
# Define OS
locals {
  allowed_os = {
    "amazon" : { owner : "amazon", filter : "amzn2-ami-hvm*" },
    "suse" : { owner : "amazon", filter : "*suse*" },
    "RHEL" : { owner : "amazon", filter : "*RHEL*" },
    #"ubuntu20" : { owner : "amazon", filter : "*ubuntu-focal-20.04-amd64-server-20230328" },
    "ubuntu22" : { owner : "099720109477", filter : "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20250425" },
    #"ubuntu22vn" : { owner : "014999276089", filter : "*asura-VNTeam" },
    #"ubuntu22arm" : { owner : "amazon", filter : "*ubuntu-jammy-22.04-arm64-minimal-20231030" },
    #"ubuntu22arm64" : { owner : "099720109477", filter : "*ubuntu-jammy-22.04-arm64-server-20230919" },
    "al2023" : { owner : "amazon", filter : "al2023-ami-2023*-x86_64" },
    "windows2022" : { owner : "amazon", filter : "Windows_Server-2022-English-Full-Base*" },
  }
  # Define Proxy GW
  proxy_gw_serverconfig = [
    for srv in var.proxy_gw_vm : {
      instance_name = "${srv.application_name}" #-${i}
      instance_type = srv.instance_type
      volume_type   = srv.volume_type
      volume_size   = srv.volume_size
      subnet_id     = srv.subnet_id
      private_ip    = srv.private_ip
      ami           = srv.ami
      tag           = srv.tag
    }
  ]
  ## Define Monitor
  monitor_serverconfig = [
    for srv in var.monitor_vm : {
      instance_name = "${srv.application_name}" #-${i}
      instance_type = srv.instance_type
      volume_type   = srv.volume_type
      volume_size   = srv.volume_size
      subnet_id     = srv.subnet_id
      private_ip    = srv.private_ip
      ami           = srv.ami
    }
  ]
  # Define App
  apps_serverconfig = [
    for srv in var.apps_vm : {
      instance_name = "${srv.application_name}" #-${i}
      instance_type = srv.instance_type
      volume_type   = srv.volume_type
      volume_size   = srv.volume_size
      subnet_id     = srv.subnet_id
      private_ip    = srv.private_ip
      ami           = srv.ami
      tag           = srv.tag
    }
  ]
}
// We need to Flatten it before using it
locals {
  proxy_gw_instances = flatten(local.proxy_gw_serverconfig)
  monitor_instances  = flatten(local.monitor_serverconfig)
  apps_instances     = flatten(local.apps_serverconfig)
}
