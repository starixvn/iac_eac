variable "project" {
  type = string
}
variable "team" {
  type = string
}

variable "dept" {
  description = "Dept name"
  type        = string
}

variable "function" {
  description = "function"
  type        = string
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
  type = string
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
  type = string
}
variable "lb_az_cross" {
  type = string
}
# variable "lb_private_ips" {
#   type        = string
# }
variable "vpc_id" {
  type = string
}
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
}

variable "eks_managed_node_groups" {
  type        = map(any)
  description = "Map of EKS managed node group definitions to create."
}

variable "autoscaling_average_cpu" {
  type        = number
  description = "Average CPU threshold to autoscale EKS EC2 instances."
}

variable "namespaces" {
  type        = list(string)
  description = "List of namespaces to be created in our EKS Cluster."
}
variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins."
}
variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers."
}
