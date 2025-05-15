project = "cloud"
team = "Lumi"
aws_region = "ap-northeast-1"
environment = "prod"
aws_profile = "prod-iac-terraform-ci"
aws_region_bucket_remote_state = "spnk-terraform-remote-state-s3"
aws_region_key_remote_state    = "spnk-terraform-akira-vpc.tfstate"
aws_region_bucket_remote_state_vn = "cloud-lumi-starix-tf-ghost"
aws_region_key_sg_remote_state_vn = "env:/prod/lumi-sg-tf.tfstate"

vpc_id = "vpc-083b51ed3f83c5096"
vpc_private_subnets = [
  "subnet-0a8d5a1eef57bb185",
  "subnet-0cb97999f4cf68d03",
  "subnet-0bbd3d3adba525a51"
]

##################
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "private_ip" : "10.88.55.100",
  },
  {
    "application_name" : "proxy-gw-02",
    "private_ip" : "10.88.56.100",
  },
]
mon_server_configuration = []
web_server_configuration = []
ansbile_server_configuration = [
  {
    "application_name" : "ansible-01",
    "private_ip" : "10.88.55.107",
  },
]
ansible_server_configuration = []
registry_server_configuration = []