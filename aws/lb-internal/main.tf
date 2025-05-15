# Terraform AWS Application Load Balancer (ALB)
module "internal_proxy_gw_v1" {
  source  = "gitlab.nexdev.net/iac/aws-alb/aws"
  version = "8.6.1"
  name               = lower("${var.team}-${var.environment}-nlb-proxy-gw-v1")
  load_balancer_type = "network"
  vpc_id = var.vpc_id
  subnets = [
    var.vpc_private_subnets[0],
    var.vpc_private_subnets[1],
  ]
  security_groups = [data.terraform_remote_state.sg.outputs.public_app_sg]
  enable_cross_zone_load_balancing = true
  internal = true
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
    {
      port               = 8882
      protocol           = "TCP"
      target_group_index = 3
    },
    {
      port               = 5055
      protocol           = "TCP"
      target_group_index = 4
    },
    {
      port               = 8081
      protocol           = "TCP"
      target_group_index = 5
    },
    {
      port               = 8885
      protocol           = "TCP"
      target_group_index = 6
    },
    {
      port               = 22222
      protocol           = "TCP"
      target_group_index = 7
    },
  ]

  # Target Groups
  target_groups = [
    {
      name                 = lower("${var.team}-${var.environment}-gw-80-v1")
      backend_protocol     = "TCP"
      backend_port         = 80
      target_type          = "ip" #"ip" instance alb
      deregistration_delay = 10
      protocol_version     = "HTTP1"
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
      name                 = lower("${var.team}-${var.environment}-gw-8088-v1")
      backend_protocol     = "TCP"
      backend_port         = 8088
      target_type          = "ip"
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
      name                 = lower("${var.team}-${var.environment}-gw-8080-v1")
      backend_protocol     = "TCP"
      backend_port         = 8080
      target_type          = "ip"
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
    {
      name                 = lower("${var.team}-${var.environment}-ansible-8882-v1")
      backend_protocol     = "TCP"
      backend_port         = 8882
      target_type          = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.ansible_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 8882
        }
      }
    },
    {
      name                 = lower("${var.team}-${var.environment}-registry-5055-v1")
      backend_protocol     = "TCP"
      backend_port         = 5055
      target_type          = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.registry_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 5055
        }
      }
    },
    {
      name                 = lower("${var.team}-${var.environment}-zabbix-8081-v1")
      backend_protocol     = "TCP"
      backend_port         = 8081
      target_type          = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.mons_instances :
        server.instance_name => {
          target_id = server.private_ip
          port      = 8081
        }
      }
    },
    {
      name                 = lower("${var.team}-${var.environment}-dr-8885-v1")
      backend_protocol     = "TCP"
      backend_port         = 8885
      target_type          = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.apps_serverconfig :
        server.instance_name => {
          target_id = server.private_ip
          port      = 80
        }
      }
    },
    {
      name                 = lower("${var.team}-${var.environment}-dr-deployapi-v1")
      backend_protocol     = "TCP"
      backend_port         = 22222
      target_type          = "ip"
      health_check = {
        protocol            = "TCP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        timeout             = 3
      }
      # Target Group - Targets
      targets = {
        for server in local.apps_serverconfig :
        server.instance_name => {
          target_id = server.private_ip
          port      = 22222
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
