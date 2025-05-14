output "output_vn_lb_internal_v1" {
    value = {
    lb_zone_id   = module.internal_proxy_gw_v1.lb_zone_id
    lb_dns_name   = module.internal_proxy_gw_v1.lb_dns_name
  }
}
