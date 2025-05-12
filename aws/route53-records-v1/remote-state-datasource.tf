# Terraform Remote State Datasource
data "terraform_remote_state" "route53_zone" {
  backend = "s3"
  config = {
    bucket = "${var.aws_region_bucket_remote_state}"
    key    = "${var.aws_region_key_remote_state_zone}"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket = "${var.aws_region_bucket_remote_state}"
    key    = "${var.aws_region_key_remote_state_lb}"
    region = "${var.aws_region}"
  }
}