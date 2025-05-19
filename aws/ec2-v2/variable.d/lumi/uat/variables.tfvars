environment = "uat"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state = "env:/uat/lumi-sg-tf.tfstate"
vpc_id                            = "vpc-0080458809d79b6f8"
# vpc_private_subnets = [
#   "subnet-0a4e02d5e2193e3cf", 10.101.0.0/20 (4k): 10.101.0.1->10.101.15.254
#   "subnet-0108d53b24f4083e4", 10.101.16.0/20 (4k): 10.101.16.1->10.101.31.254 
#   "subnet-0b6ab739f6da6a762" 10.101.32.0/20 (4k): 10.101.32.1->10.101.47.254
# ]

##################  EC2
public_key_location  = "key/id_rsa.pub"
private_key_location = "key/id_rsa"
proxy_gw_vm = [
  {
    "application_name" : "proxy-gw-01",
    "instance_type" : "t3a.small",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0a4e02d5e2193e3cf",
    "private_ip" : "10.101.15.200",
    "tag" : "EC2"
  },
  /*  {
    "application_name" : "proxy-gw-02",
    "instance_type" : "t3.small",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ba2a5f74ec351acc",
    "private_ip" : "10.88.143.100",
    "tag" : "stopoutofworking"
  },
*/
]

monitor_vm = [
 /* {
    "application_name" : "zabbix-01",
    "instance_type" : "t3a.medium",
    "ami" : "ubuntu22",
    "volume_type" : "gp3",
    "volume_size" : "70",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.99",
  },*/
]

apps_vm = [
  /*
  {
    "application_name" : "dbuat-01",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.151",
    "tag" : "stopoutofworking"
    
  },
  {
    "application_name" : "dbuat-02",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.152",
    "tag" : "stopoutofworking"
  },
  {
    "application_name" : "dbuat-03",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.153",
    "tag" : "stopoutofworking"
  },
  {
    "application_name" : "dbsit-01",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.154",
    "tag" : "stopoutofworking"
  },
  {
    "application_name" : "dbsit-02",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.155",
    "tag" : "stopoutofworking"
  },
  {
    "application_name" : "dbsit-03",
    "instance_type" : "t4g.micro",
    "ami" : "ubuntu22arm",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.156",
    "tag" : "stopoutofworking"
  },
 
  {
    "application_name" : "dr-app01",
    "instance_type" : "t3a.large",
    "ami" : "ubuntu22vn",
    "volume_type" : "gp3",
    "volume_size" : "40",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.157",
    "tag" : "stopoutofworking"
  },
  {
    "application_name" : "dr-db01",
    "instance_type" : "m6g.medium",
    "ami" : "ubuntu22arm64",
    "volume_type" : "gp3",
    "volume_size" : "20",
    "subnet_id" : "subnet-0ae72c2068513e76b",
    "private_ip" : "10.88.127.158",
    "tag" : "stopoutofworking"
  },
   */
]
