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

variable "aws_region_bucket_remote_state" {
  description = "aws_region_bucket"
  type        = string
}
variable "aws_region_key_remote_state" {
  description = "aws_region_key"
  type        = string
}

variable "aws_region_key_remote_state_zone" {
  type = string
}
variable "aws_region_key_remote_state_lb" {
  type = string
}

#######ROUTE 53
variable "domain_ns_records" {
  description = "domain ns records"
  default     = [{}]
}
variable "main_records" {
  description = "Records for Cluster VIP"
  default     = [{}]
}
variable "cluster_cname_records" {
  description = "Records CNAME for each Cluster VIP"
  default     = [{}]
}
