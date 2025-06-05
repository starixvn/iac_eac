# create Admins & Developers user maps
locals {
  admin_user_map_users = [
    for admin_user in var.admin_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${admin_user}"
      username = admin_user
      groups   = ["system:masters"]
    }
  ]
  developer_user_map_users = [
    for developer_user in var.developer_users :
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${developer_user}"
      username = developer_user
      groups   = ["${var.team}-developers"]
    }
  ]
}


module "eks_aws_auth" {

  source  = "gitlab.nexdev.net/iac/aws-eks/aws//modules/aws-auth"
  version = "20.35.0"
  #create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  # Add admin and developer users
  aws_auth_users = concat(local.admin_user_map_users, local.developer_user_map_users)

  depends_on = [module.cluster]

}