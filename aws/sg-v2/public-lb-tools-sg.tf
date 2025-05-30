# Security Group for Public Load Balancer
module "lb_tools_sg_v2" {
  source  = "gitlab.nexdev.net/iac/security-group/aws"
  version = "5.0.0"

  name        = lower("${var.team}-${var.environment}-lb-tools-sg")
  description   = "Managed by vnTerraform"
  vpc_id      = var.vpc_id
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 22222
      to_port     = 22222
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 9000
      to_port     = 9001
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 10051
      to_port     = 10052
      protocol    = 6
      description = "Allow Zabbix Proxy"
      cidr_blocks = var.allow_internet
    },
  ]
}
#################
module "lb_app_sg_v2" {
  source  = "gitlab.nexdev.net/iac/security-group/aws"
  version = "5.0.0"

  name        = lower("${var.team}-${var.environment}-lb-app-sg")
  description   = "Managed by vnTerraform"
  vpc_id      = var.vpc_id
  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags         = local.common_tags

  # Open to CIDRs blocks (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = 6
      description = "Allow Whitelist"
      cidr_blocks = var.allow_whitelist
    },
  ]
}
