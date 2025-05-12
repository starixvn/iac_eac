output "route53_zone" {
  description = "route53 zone"
  value = module.zones
  #value = module.zones["*"].route53_zone_zone_id
  #route53_zone_name_servers
}
