#SG

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "${var.aws_region_bucket_remote_state_vn}"
    key    = "${var.aws_region_key_sg_remote_state_vn}"
    region = "${var.aws_region}"
  }
}
