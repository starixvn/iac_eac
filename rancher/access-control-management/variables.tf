variable "cluster_org" {
  description = "Cluster Organization"
  type        = string
}

variable "cluster_env" {
  description = "Cluster Environment"
  type        = string
}

variable "rancher-url" {
  description = "Nested map of Rancher URL: org > env > url"
  type        = map(map(string))
  default = {
    starix = {
      kbt = "https://rancher.starixplay.com"
      sit = "https://rancher.playonesit.com"
    }
    lumi = {
      local = "https://rancher.lumigame.com"
    }
  }
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
