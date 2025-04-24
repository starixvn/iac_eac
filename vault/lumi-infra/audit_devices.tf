resource "vault_audit" "file_device" {
  for_each = { for idx, device in var.audit_devices : idx => device if device.type == "file" }
  type     = "file"
  options  = each.value.options
}

resource "vault_audit" "socket_device" {
  for_each = { for idx, device in var.audit_devices : idx => device if device.type == "socket" }
  type     = "socket"
  path     = "socket"
  local    = false
  options  = each.value.options
}
