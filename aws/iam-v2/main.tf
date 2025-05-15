####################################################V1
module "iam_assumable_role_custom_trust_policy_v2" {
  source                  = "gitlab.nexdev.net/iac/aws-iam/aws//modules/iam-assumable-role"
  version                 = "5.17.1"
  create_role             = true
  create_instance_profile = true
  role_name               = lower("${var.team}-${var.environment}-EC2-Role-v2")

  custom_role_trust_policy = data.aws_iam_policy_document.custom_trust_policy_v2.json
  custom_role_policy_arns  = ["${module.iam_policy_v2.arn}"]
  tags                     = local.common_tags
}

data "aws_iam_policy_document" "custom_trust_policy_v2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "iam_policy_v2" {
  source  = "gitlab.nexdev.net/iac/aws-iam/aws//modules/iam-policy"
  version = "5.17.1"

  name        = lower("${var.team}-${var.environment}-EC2-Policy-v2")
  path        = "/"
  description = "Managed by vnTerraform"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ssm:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ssmmessages:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ec2messages:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ec2:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "ds:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF

  tags = local.common_tags
}
###################
module "iam_policy_cloud_watch_v1" {
  source  = "gitlab.nexdev.net/iac/aws-iam/aws//modules/iam-policy"
  version = "5.17.1"

  name        = lower("${var.team}-${var.environment}-CloudWatch-Policy-v1")
  path        = "/"
  description = "Managed by vnTerraform"

  policy = <<EOF
{
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ],
    "Version": "2012-10-17"
}
EOF

  tags = local.common_tags
}