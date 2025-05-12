variable "aws_region" {
  description = "aws region"
  type        = string
}

variable "aws_profile" {
  description = "aws profile"
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

variable "domain_zones" {
  description = "domain_zones"
  default     = [{}]
}
#######ROUTE 53
variable "domain_records" {
  description = "domain_records"
  default     = [{}]
}
variable "domain_ns_records" {
  description = "domain ns records"
  default     = [{}]
}
