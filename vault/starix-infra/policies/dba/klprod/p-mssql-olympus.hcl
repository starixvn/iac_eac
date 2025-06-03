#20241009@Brice: add policy for logins: wsv_nap, dwrs, wsv_owp, wsv_hermes, wsv_rms,wsv_pol
#20241126@Brice: add login fin
#20250221@Brice: add login wsv_tgrs

path "pontus/data/database/credentials/wsv_nap" {
  capabilities = ["read", "list"]
}
path "pontus/data/database/credentials/wsv_owp" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_hermes" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/dwrs" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_rms" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_pol" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/fin" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_tgrs" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/alias" {
  capabilities = ["read", "list"]
}



