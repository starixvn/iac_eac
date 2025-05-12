environment = "uat"
project = "vn"
team = "lumi"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state    = "spnk-terraform-remote-state-s3"
aws_region_key_remote_state       = "spnk-terraform-akira-vpc.tfstate"
aws_region_key_iam_remote_state   = "spnk-terraform-asura-vpc-ec2-iam.tfstate"
aws_region_bucket_remote_state_vn = "vn-lumi-starix-tf-state"
aws_region_key_sg_remote_state_vn = "env:/uat/lumi-sg-tf.tfstate"
vpc_id                            = "vpc-0080458809d79b6f8"
# vpc_private_subnets = [
#   "subnet-04c72431b574d41fc", 10.100.144.0/21 (2046): 10.100.144.1->10.100.151.254
#   "subnet-04fb2d663dfa2959c", 10.100.152.0/21 (2046): 10.100.152.1->10.100.159.254 
#   "subnet-0a93fc87114aeced5" 10.100.160.0/21 (2046): 10.100.160.1->10.100.167.254
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
    "subnet_id" : "subnet-04c72431b574d41fc",
    "private_ip" : "10.100.151.200",
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
