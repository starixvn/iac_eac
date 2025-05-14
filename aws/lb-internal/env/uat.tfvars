project = "cloud"
team = "Lumi"
aws_region = "ap-northeast-1"
environment = "uat"
aws_profile = "uat-iac-terraform-ci"
aws_region_bucket_remote_state = "spnk-terraform-remote-state-s3"
aws_region_key_remote_state    = "spnk-terraform-akira-vpc.tfstate"
aws_region_bucket_remote_state_vn = "cloud-lumi-starix-tf-ghost"
aws_region_key_sg_remote_state_vn = "env:/uat/lumi-sg-tf.tfstate"

vpc_id = "vpc-083b51ed3f83c5096"
vpc_private_subnets = [
  "subnet-0ae72c2068513e76b",
  "subnet-0ba2a5f74ec351acc",
  "subnet-0b6ab739f6da6a762"
]

##################
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "private_ip" : "10.88.127.100",
  },
  {
    "application_name" : "proxy-gw-02",
    "private_ip" : "10.88.143.100",
  },
]

web_server_configuration = [
  {
    "application_name" : "swarm-01",
    "private_ip" : "10.88.127.157",
  },
]
mon_server_configuration = [
  {
    "application_name" : "zabbix-01",
    "private_ip" : "10.88.127.99",
  },
]
ansible_server_configuration = [
  {
    "application_name" : "ansible-01",
    "private_ip" : "10.88.55.107",
  },
]
registry_server_configuration = [
  {
    "application_name" : "registry-02",
    "private_ip" : "10.88.55.109",
  },
]
