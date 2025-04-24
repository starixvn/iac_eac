resource "vault_auth_backend" "userpass" {
  type = "userpass"
  tune {
    ## enough for good day of work
    default_lease_ttl = "10h"
  }
}

# Create userpass
resource "vault_generic_endpoint" "userpass" {
  for_each             = { for user in local.vault_users_config : user.username => user }
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${each.value.username}"
  ignore_absent_fields = true
  data_json            = <<EOT
  {
    "password": "changeme"
  }
  EOT
}

resource "vault_generic_endpoint" "userpass_readonly" {
  for_each             = { for user in local.vault_users_readonly_config : user.username => user }
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${each.value.username}"
  ignore_absent_fields = true
  data_json            = <<EOT
  {
    "password": "changeme"
  }
  EOT
}
#"policies": ["${each.value.policy}"],
###############
resource "vault_token" "prometheus_token" {
  #role_name = "prometheus-role"
  policies  = ["prometheus"]
  renewable = true
  ttl       = "24h"

  renew_min_lease = 43200
  renew_increment = 86400

  metadata = {
    "purpose" = "service-account"
  }
}

################## KUBERNETS AUTH ##################
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "role" {
  for_each                         = { for role in local.vault_kubernetes_auth_role : role.role_name => role }
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = each.value.role_name
  bound_service_account_names      = ["${each.value.sa_name}"]
  bound_service_account_namespaces = ["${each.value.sa_namespace}"]
  token_ttl                        = 3600
  token_policies                   = each.value.policies
  # audience                         = "vault"
}
