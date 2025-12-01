environment                     = "prod"
project                         = "AT"
dept                            = "VNTeam"
team                            = "N88"
function                        = "inhouse-tools"
aws_region                      = "ap-northeast-1"
aws_region_bucket_remote_state  = "at-tf-state-s3"
aws_region_key_iam_remote_state = "env:/prod/n88-iam-tf.tfstate"
allow_whitelist                 = ["202.78.231.32/27", "120.72.109.32/29", "120.72.83.128/29", "43.198.255.129/32"]
allow_cidr_block_internal       = ["10.12.96.0/24", "10.12.97.0/24", "10.12.98.0/24"]
vpc_id                          = "vpc-0aaebd0bf8e124dcc"
lb_subnets                      = "subnet-0ae4fa62cdde25537\\,subnet-071344c53d872b97e\\,subnet-03e4a4b234a406be4"
lb_az_cross                     = "true"
create_cloudwatch_log_group     = "false"
vpc_private_subnets = [
  "subnet-0ae4fa62cdde25537",
  "subnet-071344c53d872b97e",
  "subnet-03e4a4b234a406be4"
]

autoscaling_average_cpu = 90
cluster_version         = "1.34"
eks_managed_node_groups = {
  
}

###############
namespaces = ["sample", "nexops"]
###############
admin_users     = ["tf.josh.tran", "tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
