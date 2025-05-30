
# SG for Proxy Gateway Security Groups
module "private_tool_sg_v2" {
  source      = "gitlab.nexdev.net/iac/security-group/aws"
  version     = "5.0.0"
  name        = lower("${var.team}-${var.environment}-private-tools-sg")
  description   = "Managed by vnTerraform"
  vpc_id      = var.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "http-8080-tcp", "all-icmp", "https-443-tcp"]
  ingress_cidr_blocks = var.cidr_block_internal
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8882
      to_port     = 8882
      protocol    = 6
      description = "Ansible"
      cidr_blocks = var.allow_cidr_block_internal
    },
    {
      from_port   = 5055
      to_port     = 5055
      protocol    = 6
      description = "Hub Proxy"
      cidr_blocks = var.allow_cidr_block_internal
    },
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = 6
      description = "Allow Zabbix Web"
      cidr_blocks = var.allow_cidr_block_internal
    },
    {
      from_port   = 10051
      to_port     = 10052
      protocol    = 6
      description = "Allow Zabbix Proxy"
      cidr_blocks = var.allow_cidr_block_internal #"0.0.0.0/0"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = 6
      description = "node exporter"
      cidr_blocks = var.allow_cidr_block_internal
    },
  ]
  tags = merge(
    local.common_tags,
    {
      Resource = "SG"
    },
  )
}
