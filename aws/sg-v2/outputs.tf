# SG Output Values

output "proxy_gw_sg" {
  value = module.proxy_gw_sg_v2.security_group_id
}

output "private_web_sg" {
  value = module.private_web_sg_v2.security_group_id
}

# output "private_db_sg" {
#   value = module.private_dba_sg_v2.security_group_id
# }

output "public_web_sg" {
  value = module.lb_app_sg_v2.security_group_id
}
output "public_tools_sg" {
  value = module.lb_tools_sg_v2.security_group_id
}
output "public_app_sg" {
  value = module.lb_app_sg_v2.security_group_id
}

output "private_tool_sg" {
  value = module.private_tool_sg_v2.security_group_id
}