
variable "project" {
  type = string
}
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "ap-northeast-1"
}

variable "team" {
  type = string
}

variable "allow_cidr_block_internal" {
  description = "allow ingress_cidr_blocks"
  type        = string
}

variable "cidr_block_internal" {
  description = "allow ingress_cidr_blocks"
  type        = list(string)
  default     = []
}

variable "allow_whitelist" {
  description = "allow whitelist"
  type        = string
}

variable "allow_internet" {
  description = "allow Internet"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "allow ingress_cidr_blocks"
  type        = list(string)
  default     = []
}
variable "vpc_id" {
  type = string
}
