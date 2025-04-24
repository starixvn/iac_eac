#Database rule
# Grant permissions on user specific path
path "pontus/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "auth/userpass/users/pontus" {
  capabilities = [ "update" ]
  allowed_parameters = {
    "password" = []
  }
}