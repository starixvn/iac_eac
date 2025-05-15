output "ec2_iam_name_v2" {
  description = "iam_instance_profile"
  value       = module.iam_assumable_role_custom_trust_policy_v2.iam_instance_profile_name
}

#policy_arn
output "cloud_watch_iam_role_arn" {
  description = "iam_policy_cloud_watch"
  value       = module.iam_policy_cloud_watch_v1.arn
}
#iam_role_arn