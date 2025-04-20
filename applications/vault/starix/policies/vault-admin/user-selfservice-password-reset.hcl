##
## This policies allows to: 
##   * list auth backend
##   * list users in the userpass backend
##   * read your own userpass's user config
##   * update your own password
##
## Need to be created after enabling userpass auth method

path "auth/userpass/users/{{identity.entity.name}}/password" {
  capabilities = ["update"]
  allowed_parameters = {
    "password"                = []
    "token_explicit_max_ttl"  = []
    "token_max_ttl"           = []
    "token_no_default_policy" = []
    "token_num_uses"          = []
    "token_period"            = []
    "token_ttl"               = []
    "token_type"              = []
  }
}
