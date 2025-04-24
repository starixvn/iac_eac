variable "vault_address" {
  description = "vault_address"
}

variable "region" {
  description = "AWS regions"
  default     = "ap-northeast-1"
}
#####################
## Gitlab
variable "gitlab_domain" {
  description = "The domain name of your gitlab (e.g: gitlab.com)"
  default     = "https://gitlab.nexdev.net"
}

variable "bound_gitlab_project_id" {
  description = "The pipeline ID to authorize to auth with Vault"
  default     = "2660"
}

variable "bound_gitlab_ref" {
  description = "The pipeline Ref to authorize to auth with Vault"
  default     = "main"
}

variable "bound_gitlab_ref_type" {
  description = "The pipeline Ref Type to authorize to auth with Vault"
  default     = "branch"
}

variable "gitlab_project_branch" {
  description = "The pipeline project branch to authorize to auth with Vault"
  default     = "master"
}
variable "jwt_token_max_ttl" {
  description = "The token max ttl for JWT auth backend (default: 15min)"
  default     = 1800
}
variable "jwk_gitlab_nexdev" {
  description = "Public key for jwt trust in vault"
  type        = list(string)
  default     = ["-----BEGIN PUBLIC KEY-----\nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA2/04ETbN8KaMDnwGZ1u5\n8W1RXaGuQH4VKEpFs3zuouRxCy7uMdRJ2Uz4TFs51V5wWDV/CrU85oXUXGm5jBrG\nRyfqTWos6F4iM0jzAEibvK0LotPX4kWiEi4lf1Xt5BfzR6oEG7TcHbYfqvvM9fSa\nnrzriXKquK+vLA7yxIrgVB/NId6OrsknlKOnbwLE3uC2FX2bRdKIATAxcBu3Xyl4\nYzttYqr5NrXfHo+Rr7H495kV2hjI+L1Y9NYcZ67FR3ZzrlZcAuf4EQAhhMqLOXzj\nOhaNPqAn7JYIneQNVxZw5NH3Opn2lD8KHCReMAMvvtZyANXCaqbtVo9dWsbE1s13\ntQ39m7wCzIkhHgnRxIjGeAHzgmUgarB/FI+/LJqjN/kM+K1Vip6lM6KfWYDIr31C\nh/lSOy+TBb7Rl15Rqc2ilTMzIlDhwF8nIp+/JtrH7+3emiSB7q3VXdHSI1TGzPiS\nJJ222GMf6uzJ7soGKo9vo0DlwhiThG14gUCwywxObafUliylyq6jZvVj0haAwJb2\n91P1RUfeMtbSSMtOFqASC6D6uiLydtSZ/AzPhkMcrGC0LXh9VTyGEAAF8wMTZ081\n/Q0dEep+mk1BIdhXHnXdb18HX65iHS4pi3cPagIOOEq8UVqqequrlEI3213pxe8v\n3wqRGcovlVI3YYk8LJeoaG0CAwEAAQ==\n-----END PUBLIC KEY-----", "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAojzYWT6rRbcZTxWUdTXW\n8bEBv50FElYwi67FvF/kEjzHiN8Z/t/3klDiQp/OT15SFdTRvKyjVi4Bg7omnDeJ\nPEbQCrr15qCGnB3RoR0PtWgaKN766H2cJ3/K+maIquj3PLunY3R72qiAxznJswY9\n7sIYpF6l++Qh66+C5jbGBzFTwaf4kGkxNIycUs19vW7VWLaNS/FMlM0bPaB8X6sq\nRvWQmV0N4aLOc3PkKqcWKAdYiLC6fFI4ln9sqMnHBz+cFL1kmwAVjmdBsUJA1l3d\nvnc84TKFa/InVKTEaZVCvgThC0L2O/CJQfCxqi6WWKuonSpKiJrAV/sUcFhQBnrH\n2wIDAQAB\n-----END PUBLIC KEY-----"]
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
  default     = 900
}

variable "aws_secret_max_ttl" {
  description = "The max lease ttl for AWS secret engine (default: 15min)"
  default     = 1800
}


variable "application_aws_assume_role" {
  description = "The AWS arn role for Vault to assume for AWS Secret engine. The AWS credentials are pass to the application."
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

variable "kube_auth_backends" {
  description = "Auth type backends"
  default     = [{}]
}

variable "aws_secret_backend" {
  description = "AWS Authz backends"
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
