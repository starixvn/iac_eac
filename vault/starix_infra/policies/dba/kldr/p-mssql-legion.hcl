#20241009@Brice: add policy for logins: Dot_Admin_Portal, portal, wsv_afinet, wsv_afinetv, wsv_lap, Affiliate_Api, ncb.admin, ncb.bot
#20241009@Evan: add policy for logins: asv_cust

path "pontus/data/database/credentials/wsv_nap" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/Dot_Admin_Portal" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/portal" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_afinet" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_afinetv" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/wsv_lap" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/Affiliate_Api" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/ncb.admin" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/ncb.bot" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/credentials/asv_cust" {
  capabilities = ["read", "list"]
}

path "pontus/data/database/alias" {
  capabilities = ["read", "list"]
}
