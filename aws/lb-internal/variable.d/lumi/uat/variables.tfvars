environment = "uat"
project = "vn"
team = "lumi"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state_vn = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state_vn = "env:/uat/lumi-sg-tf.tfstate"

vpc_id = "vpc-0080458809d79b6f8"
vpc_private_subnets = [
  "subnet-0a4e02d5e2193e3cf",
  "subnet-0108d53b24f4083e4",
  "subnet-0f92f11b87239fbd5"
]

##################
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "private_ip" : "10.100.151.200",
  },
]

web_server_configuration = [
]
mon_server_configuration = [
]
ansible_server_configuration = [
  {
    "application_name" : "ansible-01",
    "private_ip" : "10.100.151.207",
  },
]
registry_server_configuration = [
  {
    "application_name" : "registry-02",
    "private_ip" : "10.100.151.209",
  },
]
