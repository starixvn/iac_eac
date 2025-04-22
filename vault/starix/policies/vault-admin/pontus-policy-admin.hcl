path "sys/policies/acl/*" {
  capabilities = ["list"]
}

path "sys/policies/acl/p-mssql-*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/policies/acl/p-mysql-*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
