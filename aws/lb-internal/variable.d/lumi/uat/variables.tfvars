environment = "uat"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state_vn = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state_vn = "env:/uat/lumi-sg-tf.tfstate"

vpc_id = "vpc-0080458809d79b6f8"
vpc_private_subnets = [
  "subnet-0a4e02d5e2193e3cf",
  "subnet-0108d53b24f4083e4",
  "subnet-0b6ab739f6da6a762"
]

##################
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "private_ip" : "10.101.15.200",
  },
]

web_server_configuration = [
]
mon_server_configuration = [
]
ansible_server_configuration = [

]
registry_server_configuration = [

]
