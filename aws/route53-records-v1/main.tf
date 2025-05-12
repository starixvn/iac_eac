module "ns_records" {
  source   = "gitlab.nexdev.net/iac/aws-route53/aws//modules/records"
  version  = "2.10.2"
  for_each = { for record in local.domain_ns_config : record.name => record }
  zone_id  = data.terraform_remote_state.route53_zone.outputs.route53_zone[each.value.zone_id].route53_zone_zone_id[each.value.zone_id]
  records = [
    {
      name    = each.value.name
      type    = each.value.type
      ttl     = each.value.ttl
      records = data.terraform_remote_state.route53_zone.outputs.route53_zone[each.value.name_servers].route53_zone_name_servers[each.value.name_servers]
    },
  ]
}


######################################
##  for Cluster A records
module "main_records" {
  source    = "gitlab.nexdev.net/iac/aws-route53/aws//modules/records"
  version   = "2.10.2"
  for_each  = { for idx, zone_records in local.main_records_by_zone : idx => zone_records }
  zone_name = each.value.zone_name
  records   = each.value.records
}

module "cluster_cname_records" {
  source    = "gitlab.nexdev.net/iac/aws-route53/aws//modules/records"
  version   = "2.10.2"
  for_each  = { for idx, canonical in local.cluster_cname_records_by_zone : idx => canonical }
  zone_name = each.value.zone_name
  records   = each.value.records
}
