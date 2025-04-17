variable "rancher-url" {
  description = "rancher-url"
}

variable "clusters_ac" {
  description = "cluster_ac"
}

variable "user_groups" {
  description = "list of user groups"
}

variable "default_passwd" {
  description = "default password"
  type        = string
  default     = "KcmSQ9u3FwJ1ZMAx"
}
