
# SG for Proxy Gateway Security Groups
module "proxy_gw_sg_v2" {
  source      = "gitlab.nexdev.net/iac/security-group/aws"
  version     = "5.0.0"
  name        = lower("${var.team}-${var.environment}-proxy-gw-sg")
  description   = "Managed by vnTerraform"
  vpc_id      = var.vpc_id
  # Ingress Rules & CIDR Blocks
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "http-8080-tcp", "all-icmp", "https-443-tcp"]
  ingress_cidr_blocks = var.cidr_block_internal
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = 6
      description = "Allow Port 8088"
      cidr_blocks = var.allow_cidr_block_internal
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = 6
      description = "node exporter"
      cidr_blocks = var.allow_cidr_block_internal
    },
    {
      from_port   = 9101
      to_port     = 9101
      protocol    = 6
      description = "HAProxy Stat"
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
