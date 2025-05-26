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

variable "rancher-token" {
  description = "Nested map of Rancher Token: org > env > tokne"
  type        = map(map(string))
  default = {
    starix = {
      kbt = "token-dzqk4:h8mhgdq4vbk9mbh9sxdhdqqgctj4wthfvmqfghqrtbfq4ltxxj55f6"
    }
    lumi = {
      local = "token-vsdbk:jckh5qj8zpvg2cx7tbplpfczx4smxr7trx7fbz8bm78fxxh4d7rxgq"
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
