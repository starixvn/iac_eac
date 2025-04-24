path "pontus/data/database/mssql/db02" {
    capabilities = ["read","list"]
    }

path "pontus/data/database/mysql/dbtest" {
    capabilities = ["read","list"]
    }

path "rome/data/alpha/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
    }


path "database/creds/*" {
  capabilities = ["read"]
}

path "transit/encrypt/web" {
  capabilities = ["create", "update", "delete"]
}
