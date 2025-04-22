#####################################
resource "vault_mount" "kv_v2" {
  for_each                     = { for mount in local.vault_mount_config : mount.mount_path => mount }
  path                         = each.value.mount_path
  type                         = each.value.mount_type
  audit_non_hmac_response_keys = ["error"]
}
######### vault_generic_secret_config
resource "vault_generic_secret" "vault_generic_secret_v1" {
  depends_on = [vault_mount.kv_v2]
  for_each   = { for user in local.vault_generic_secret_config : user.username => user }
  path       = each.value.path
  data_json  = <<EOT
    {
    "username": "${each.value.username}",
    "password": "${each.value.password}"
    }
    EOT
}
