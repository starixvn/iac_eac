#20241009@Brice: add policy for logins: asv_hit, Dot_Admin_Portal, vnrome, wsv_alp, wsv_alpv, wsv_lap, wsv_xnap


path "pontus/data/database/credentials/wsv_nap" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/asv_hit" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/Dot_Admin_Portal" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/vnrome" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_alpv" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_alp" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_lap" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_xnap" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/alias" {
  capabilities = ["read", "list"]
}



