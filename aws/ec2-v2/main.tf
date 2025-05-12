/* Proxy GW */
module "proxy_gw_v1" {
  source        = "gitlab.nexdev.net/iac/ec2-instance/aws"
  version       = "5.2.1"
  for_each      = { for server in local.proxy_gw_instances : server.instance_name => server }
  instance_type = each.value.instance_type
  name          = lower("vn-${var.team}-${var.environment}-${each.key}")
  ami           = data.aws_ami.os[each.value.ami].id
  subnet_id     = each.value.subnet_id
  #vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.proxy_gw_sg]
  private_ip         = each.value.private_ip
  hibernation        = false
  enable_volume_tags = false
  root_block_device = [{
    volume_type           = each.value.volume_type
    volume_size           = each.value.volume_size
    delete_on_termination = false
    tags = merge(
      local.common_tags,
      {
        Name = lower("${var.team}-${var.environment}-${each.key}")
      },
    )
  }]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
  }
  user_data = file("${path.module}/proxy_gw_prepare.sh")
  instance_tags = {
    OS = each.value.ami,
  }
  #iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_iam_name
  tags = merge(
    local.common_tags,
    {
      Resource = each.value.tag
    },
  )
}

module "app_v1" {
  source        = "gitlab.nexdev.net/iac/ec2-instance/aws"
  version       = "5.2.1"
  for_each      = { for server in local.apps_instances : server.instance_name => server }
  instance_type = each.value.instance_type
  name          = lower("vn-${var.team}-${var.environment}-${each.key}")
  ami           = data.aws_ami.os[each.value.ami].id
  subnet_id     = each.value.subnet_id
  # vpc_security_group_ids = [
  #   data.terraform_remote_state.sg.outputs.private_web_sg,
  #   ]
  private_ip         = each.value.private_ip
  hibernation        = false
  enable_volume_tags = false
  root_block_device = [{
    volume_type           = each.value.volume_type
    volume_size           = each.value.volume_size
    delete_on_termination = false
    tags = merge(
      local.common_tags,
      {
        Name = lower("${var.team}-${var.environment}-${each.key}")
      },
    )
  }]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
  }
  user_data = file("${path.module}/linux_prepare.sh")
  instance_tags = {
    OS = each.value.ami,
  }
  #iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_iam_name
  tags = merge(
    local.common_tags,
    {
      Resource = each.value.tag
    },
  )
}
