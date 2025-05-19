variable "project" {
  type = string
}
variable "team" {
  type = string
}

variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}
variable "aws_region_bucket_remote_state" {
  description = "aws_region_bucket VN"
  type        = string
}

variable "aws_region_key_iam_remote_state" {
  description = "iam_remote_state"
  type        = string
}

variable "cluster_version" {
  type        = string
}
variable "allow_whitelist" {
  description = "allow whitelist"
  type        = list(string)
  default     = []
}
variable "allow_cidr_block_internal" {
  description = "allow cidr_block_internal"
  type        = list(string)
  default     = []
}
variable "create_cloudwatch_log_group" {
  description = "create_cloudwatch_log_group"
  type        = string
  default     = "true"
}
variable "lb_subnets" {
  type        = string
}
variable "lb_az_cross" {
  type        = string
}
# variable "lb_private_ips" {
#   type        = string
# }
variable "vpc_id" {
  type        = string
}
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
}