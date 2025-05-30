# Terraform AWS Application Load Balancer (ALB)
module "internal_proxy_gw_v1" {
  source             = "gitlab.nexdev.net/iac/aws-alb/aws"
  version            = "8.6.1"
  name               = lower("${var.team}-${var.environment}-nlb-proxy-gw-v1")
  load_balancer_type = "network"
  vpc_id             = var.vpc_id
  subnets = [
    var.vpc_private_subnets[0],
    var.vpc_private_subnets[1],
  ]
  security_groups                  = [data.terraform_remote_state.sg.outputs.public_app_sg]
  enable_cross_zone_load_balancing = true
  internal                         = true
  # Listeners
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 8088
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 8080
      protocol           = "TCP"
      target_group_index = 2
    },
  ]

  # Target Groups
  target_groups = [
    {
      name                 = lower("${var.team}-${var.environment}-gw80-v1")
      backend_protocol     = "TCP"
      backend_port         = 80
      target_type          = "ip" #"ip" instance alb
      deregistration_delay = 10
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      preserve_client_ip = true
      stickiness = {
        enabled = false
        type    = "source_ip"
      }
      # Target Group - Targets
      targets = {
        for server in local.proxy_gw_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 80
        }
      }
      tags = local.common_tags # Target Group Tags
    },
    {
      name             = lower("${var.team}-${var.environment}-gw8088-v1")
      backend_protocol = "TCP"
      backend_port     = 8088
      target_type      = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.proxy_gw_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 8088
        }
      }
    },
    {
      name             = lower("${var.team}-${var.environment}-gw8080-v1")
      backend_protocol = "TCP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.proxy_gw_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 8080
        }
      }
    },
  ]
  tags = merge(
    local.common_tags,
    {
      Resource = "LB"
    },
  )
}
