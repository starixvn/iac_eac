environment = "prod"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state = "env:/prod/lumi-sg-tf.tfstate"
aws_region_key_iam_remote_state = "env:/uat/lumi-iam-tf.tfstate"
vpc_id                            = "vpc-0080458809d79b6f8"
/*
vpc_private_subnets = [
  "subnet-0613fbd221a805b5b",
  "subnet-013bce3c7a2d4020c",
  "subnet-0475b4fa8ffc80ab7"
]
#   "subnet-0613fbd221a805b5b", 10.101.48.0/21 (2046): 10.101.48.1->10.101.55.254
#   "subnet-013bce3c7a2d4020c", 10.101.56.0/21 (2046): 10.101.56.1->10.101.63.254
#   "subnet-0475b4fa8ffc80ab7" 10.101.64.0/21(2046): 10.101.64.1->10.101.71.254
*/
##################  EC2
public_key_location = "key/id_rsa.pub"
private_key_location = "key/id_rsa"
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "instance_type" : "t3a.small",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0613fbd221a805b5b",
    "private_ip" : "10.101.55.248",
    "tag" : "EC2"
  },
  {
    "application_name" : "proxy-gw-02",
    "instance_type" : "t3.small",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-013bce3c7a2d4020c",
    "private_ip" : "10.101.63.248",
    "tag" : "EC2"
  },

]

monitor_vm = [
  /*
  {
    "application_name" : "ansible-01",
    "instance_type" : "t3a.medium",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "60",
    "subnet_id" : "subnet-0613fbd221a805b5b",
    "private_ip" : "10.101.55.240",
    "tag" : "EC2"
  },
  {
    "application_name" : "registry-02",
    "instance_type" : "t3a.medium", ### Upgrade specs hub
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "50",
    "subnet_id" : "subnet-0613fbd221a805b5b",
    "private_ip" : "10.101.55.241",
    "tag" : "EC2"
  },
  */
]
## Zone A: subnet-0613fbd221a805b5b C: subnet-013bce3c7a2d4020c D: subnet-0bbd3d3adba525a51
apps_vm = [
]