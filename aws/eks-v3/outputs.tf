################################################################################
# Cluster
################################################################################


output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.cluster.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.cluster.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.cluster.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.cluster.cluster_certificate_authority_data
}
