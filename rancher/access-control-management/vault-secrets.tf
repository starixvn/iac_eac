variable "vault_addr" {
  description = "Vault Addr Server to archive secrets"
  type        = string
  default     = "https://vault.nexdev.net"
}

variable "vault_secrets" {
  description = "Map of Vault Secret Object"
  type = map(object({
    mount = string
    path  = string
  }))
  default = {}
}


provider "vault" {
  address          = var.vault_addr
  skip_child_token = true #https://stackoverflow.com/questions/73034161/permission-denied-on-vault-terraform-provider-token-creation
}

data "vault_kv_secret_v2" "secrets" {
  for_each = var.vault_secrets
  mount    = each.value.mount
  name     = each.value.path
}
