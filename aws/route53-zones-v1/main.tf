module "zones" {
  source  = "gitlab.nexdev.net/iac/aws-route53/aws//modules/zones"
  version = "2.10.2"
  for_each = { for domain_zone in local.domain_zone_config : domain_zone.domain => domain_zone }
  zones = {
  "${each.value.domain}"= {
      comment = "${each.value.domain} - ${local.project}-${var.environment}"
      tags = {
        Name = "${each.value.domain}"
      }
    },
  }

  tags = merge(
    local.common_tags,
    {
      Resource = "Route53"
    },
  )
}
