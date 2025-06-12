
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
variable "aws_region_bucket_remote_state" {
  description = "aws_region_bucket"
  type        = string
}
variable "aws_region_key_sg_remote_state" {
  description = "sg_remote_state"
  type        = string
}
variable "aws_region_key_iam_remote_state" {
  description = "iam_remote_state"
  type        = string
}

variable "team" {
  type = string
}
variable "proxy_gw_vm" {
  description = "EC2 configuration"
  default     = [{}]
}
variable "apps_vm" {
  description = "EC2 configuration"
  default     = [{}]
}

variable "monitor_vm" {
  description = "EC2 configuration"
  default     = [{}]
}

variable "private_key_location" {
  type = any
}

variable "public_key_location" {
  type = any
}
variable "ami_name" {
  default = "ubuntu22"

  validation {
    condition     = can(regex("amazon|suse|RHEL|ubuntu|windows", var.ami_name))
    error_message = "Invalid ami name, allowed_values = [amazon suse RHEL ubuntu]."
  }
}

variable "vpc_id" {
  type = string
}