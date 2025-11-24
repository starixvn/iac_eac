variable "aws_region" {
  description = "aws region"
  type        = string
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "project" {
  type = string
}

variable "access_key_arn" {
  type = string
}

# variable "ingress_cidr_blocks" {
#   description = "allow ingress_cidr_blocks"
#   type        = list(string)
#   default     = []
# }
