module "ebs_csi_irsa_role" {
  source = "gitlab.nexdev.net/iac/aws-iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.17.1"
  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
# create EKS cluster
module "cluster" {
  source = "gitlab.nexdev.net/iac/aws-eks/aws"
  version = "19.21.0"

  cluster_name                    = lower("${var.team}-${var.environment}-eks")
  cluster_version                 = "${var.cluster_version}"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = var.allow_whitelist
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  cluster_enabled_log_types = ["scheduler", "controllerManager"]
  #cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"] #default     = ["audit", "api", "authenticator"]
  # Extend node-to-node security group rules 10.77.0.0/16 10.88.0.0/16
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = var.allow_cidr_block_internal
      type        = "ingress"
      #self        = true
    }
  }
  cluster_addons = {
    coredns = {
      #most_recent = true
      addon_version = "v1.11.4-eksbuild.2" #"v1.10.1-eksbuild.5"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
      addon_version = "v1.30.9-eksbuild.3" #"v1.27.6-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      most_recent              = true
      addon_version = "v1.19.2-eksbuild.5" #"v1.15.3-eksbuild.1"
      before_compute           = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-ebs-csi"
      most_recent              = true
      addon_version = "v1.24.1-eksbuild.1"
      resolve_conflicts="PRESERVE"
    }
  }
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.vpc_private_subnets
  eks_managed_node_groups         = var.eks_managed_node_groups
  iam_role_additional_policies = {
      additional = data.terraform_remote_state.iam.outputs.cloud_watch_iam_role_arn
    }
  tags = merge(
    local.common_tags,
    {
      Resource = "EKS"
    },
  )

}

# set spot fleet Autoscaling policy
resource "aws_autoscaling_policy" "eks_autoscaling_policy" {
  count = length(var.eks_managed_node_groups)

  name                   = "${module.cluster.eks_managed_node_groups_autoscaling_group_names[count.index]}-autoscaling-policy"
  autoscaling_group_name = module.cluster.eks_managed_node_groups_autoscaling_group_names[count.index]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.autoscaling_average_cpu
  }

}
