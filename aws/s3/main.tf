module "s3_bucket" {
  source                   = "gitlab.nexdev.net/iac/aws-s3/aws"
  version                  = "5.8.1" #"3.15.2"
  bucket                   = "${var.team}-${var.project}-${var.environment}"
  region                   = var.aws_region
  attach_policy            = true
  policy                   = data.aws_iam_policy_document.bucket_policy.json
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  versioning = {
    enabled = false
  }

  tags = merge(
    local.common_tags,
    {
      Resource = "S3"
    },
  )
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#################################

data "aws_iam_policy_document" "bucket_policy" {
  # Public access for viewing (ListBucket, GetObject)
  statement {
    sid = "PublicView"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.team}-${var.project}-${var.environment}",
      "arn:aws:s3:::${var.team}-${var.project}-${var.environment}/*"
    ]
    # No condition: allow from all internet
  }

  # Restricted access for insert/update/delete (PutObject, DeleteObject, etc.)
  statement {
    sid = "RestrictedWrite"
    principals {
      type        = "AWS"
      identifiers = [var.access_key_arn] # You should pass the ARN of the IAM user/role with AccessKey/SecretKey
    }
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.team}-${var.project}-${var.environment}/*"
    ]
  }
}

