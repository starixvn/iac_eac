project = "clouddemo"
team = "Lumi"
aws_region = "ap-northeast-1"
environment = "testlab"
aws_profile = "test-iac-terraform-ci"
aws_region_bucket_remote_state = "clouddemo-lumi-starix-tf-terrapin"
aws_region_key_remote_state    = "env:/testlab/vpc-terraform.tfstate"
aws_region_key_remote_state_acm    = "env:/testlab/route53-acme-certificate-tf.tfstate"

################  EC2
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "instance_type" : "t3.micro",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "20",
    "private_ip" : "10.6.32.10",
  },
]
apps_vm = [
  {
    "application_name" : "app-01",
    "instance_type" : "t3.micro",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "20",
    "private_ip" : "10.6.32.100",
  },
]
