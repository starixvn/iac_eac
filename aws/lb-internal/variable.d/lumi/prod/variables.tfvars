environment = "prod"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state_vn = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state_vn = "env:/prod/lumi-sg-tf.tfstate"

vpc_id = "vpc-0080458809d79b6f8"
vpc_private_subnets = [
  "subnet-0613fbd221a805b5b",
  "subnet-013bce3c7a2d4020c",
  "subnet-0475b4fa8ffc80ab7"
]

##################
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "private_ip" : "10.101.55.248",
  },
]

web_server_configuration = [
]
mon_server_configuration = [
]
ansible_server_configuration = [
  {
    "application_name" : "ansible-01",
    "private_ip" : "10.101.55.240",
  },
]
registry_server_configuration = [
  {
    "application_name" : "registry-01",
    "private_ip" : "10.101.55.241",
  },
]
