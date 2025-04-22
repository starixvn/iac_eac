variable "vault_address" {
  description = "vault_address"
}

variable "region" {
  description = "AWS regions"
  default     = "ap-northeast-1"
}
#####################
# Gitlab
variable "gitlab_domain" {
  description = "The domain name of your gitlab (e.g: gitlab.com)"
  default     = "gitlab.nexdev.net"
}

variable "gitlab_project_id" {
  description = "The pipeline ID to authorize to auth with Vault"
  default     = "2702"
}

variable "gitlab_project_branch" {
  description = "The pipeline project branch to authorize to auth with Vault"
  default     = "master"
}
variable "jwt_token_max_ttl" {
  description = "The token max ttl for JWT auth backend (default: 15min)"
  default     = 1800
}

variable "jwt_auth_tune_default_ttl" {
  description = "The tune default lease ttl for JWT auth backend (default: 10min)"
  default     = "15m"
}
variable "jwt_auth_tune_max_ttl" {
  description = "The tune max lease ttl for JWT auth backend (default: 15min)"
  default     = "30m"
}
variable "aws_secret_default_ttl" {
  description = "The default lease ttl for AWS secret engine (default: 10min)"
  default     = 1800
}

variable "aws_secret_max_ttl" {
  description = "The max lease ttl for AWS secret engine (default: 15min)"
  default     = 3600
}
#####################
# MANDATORY
variable "polices" {
  description = "polices"
  default     = [{}]
}

variable "roles" {
  description = "roles"
  default     = [{}]
}

variable "auth_userpass" {
  description = "auth userpass"
  default     = [{}]
}

variable "vault_mount" {
  description = "vault mount"
  default     = [{}]
}

variable "vault_generic_secret" {
  description = "vault generic secret"
  default     = [{}]
}

variable "entities" {
  description = "A set of vault clients to create"
  # Keep nginx as the first vault client for docker-compose demo using AppRole. Please append additional apps to the list
  default = [
    "nginx",
    "app100"
  ]
}

variable "audit_devices" {
  description = "Vault audit device"
  default     = [{ type = null }]
}
##############################
variable "env" {
  description = "Environment Variable used as a prefix"
  type        = string
}
variable "vault_team" {
  description = "Team Variable used as a prefix"
  type        = list(string)
  default     = []
}
##
## ALL Vault Users
##
### NOTE: you must declare all users
###       first in this list.
variable "vault_users" {
  description = "All vault users"
  default     = [{}]
}

variable "vault_users_readonly" {
  description = "All vault users Readonly"
  default     = [{}]
}

##
## Vault Admin Users
##
variable "vault_admin_users" {
  description = "Vault Admin users"
  type        = list(string)
  default     = []
}

##
## Dev Users
##
variable "pki_team_users" {
  description = "PKI Team users"
  type        = list(string)
  default     = []
}


/*** Env ***/
##
## Admin Users
##
variable "admin_users" {
  description = "Admin users"
  type        = list(string)
  default     = []
}

##
## Read Only All Users
##
variable "readonly_users" {
  description = "Readonly users"
  type        = list(string)
  default     = []
}

variable "kubernetes_auth_role" {
  description = "Roles for kubernetes auth method"
  default     = [{}]
}

/**** userpass Entity Alias ****/
### the username/password will be created via the 
### vault UI, but the mapping of username to a vault 
### entity is managed via terraform
variable "vault_userpass_entity_aliases" {
  description = "Mapping of vault users (entities) to userpass username alias"
  type        = map(string)
  default     = {}
}

################ CONSTANT VARIABLE ################
variable "CIDR_OFFICE" {
  description = "VN Office CIDR"
  type        = list(string)
  default     = []
}
