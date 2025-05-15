project = "cloud"
team = "Lumi"
aws_region = "ap-northeast-1"
environment = "uat"
aws_profile = "uat-iac-terraform-ci"
aws_region_bucket_remote_state = "spnk-terraform-remote-state-s3"
aws_region_key_remote_state    = "spnk-terraform-akira-vpc.tfstate"
aws_region_bucket_remote_state_vn = "cloud-lumi-starix-tf-ghost"
aws_region_key_iam_remote_state = "env:/uat/lumi-iam-tf.tfstate"
allow_whitelist = ["202.78.231.32/27","120.72.109.32/29","120.72.83.128/29","43.198.255.129/32"]
allow_cidr_block_internal = ["10.88.112.0/20","10.88.128.0/20","10.88.144.0/20","10.77.15.0/24","10.77.25.0/24","10.88.48.0/21","10.88.56.0/21","10.88.64.0/21"] #["10.77.0.0/16","10.88.0.0/16"] #
vpc_id = "vpc-083b51ed3f83c5096"
lb_subnets = "subnet-0ae72c2068513e76b\\,subnet-0ba2a5f74ec351acc\\,subnet-0f92f11b87239fbd5"
lb_az_cross = "true"
create_cloudwatch_log_group = "false"
#lb_private_ips = "10.88.112.250\\,10.88.143.250\\,10.88.159.250"
vpc_private_subnets = [
  "subnet-0ae72c2068513e76b",
  "subnet-0ba2a5f74ec351acc",
  "subnet-0f92f11b87239fbd5"
]
autoscaling_average_cpu = 90
cluster_version = "1.30"
eks_managed_node_groups = {
  ######### HAPROXY Ingress
  "vn-lumi-uat-eks-ing1" = {
    name            = "vn-lumi-uat-eks-ing1"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
            "haproxy" = "yes"
          }
    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.medium"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "ON_DEMAND"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    #### device_name = "/dev/sdh"
    schedules = {

      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=110/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
######## APP SPOT
  "vn-lumi-uat-eks-sp5" = {
    name            = "vn-lumi-uat-eks-sp5"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes",
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "gn-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "gn-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "gn-games-backend" = "yes"
            "sp-api" = "yes"
            "sp-games" = "yes"
            "sp-games-backend" = "yes"
            "sk-api" = "yes"
            "sk-games" = "yes"
            "sk-games-backend" = "yes"
            "tg-api" = "yes"
            "tg-games" = "yes"
            "tg-games-backend" = "yes"
            "hd-api" = "yes"
            "hd-games" = "yes"
            "hd-games-backend" = "yes"
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 60
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    ####
    schedules = {

      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  "vn-lumi-uat-eks-sp4" = {
    name            = "vn-lumi-uat-eks-sp4"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes",
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "gn-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "gn-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "gn-games-backend" = "yes"
            "sp-api" = "yes"
            "sp-games" = "yes"
            "sp-games-backend" = "yes"
            "sk-api" = "yes"
            "sk-games" = "yes"
            "sk-games-backend" = "yes"
            "tg-api" = "yes"
            "tg-games" = "yes"
            "tg-games-backend" = "yes"
            "hd-api" = "yes"
            "hd-games" = "yes"
            "hd-games-backend" = "yes"
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 60
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    ####
    schedules = {

      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  "vn-lumi-uat-eks-sp3" = {
    name            = "vn-lumi-uat-eks-sp3"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes",
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "gn-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "gn-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "gn-games-backend" = "yes"
            "sp-api" = "yes"
            "sp-games" = "yes"
            "sp-games-backend" = "yes"
            "sk-api" = "yes"
            "sk-games" = "yes"
            "sk-games-backend" = "yes"
            "tg-api" = "yes"
            "tg-games" = "yes"
            "tg-games-backend" = "yes"
            "hd-api" = "yes"
            "hd-games" = "yes"
            "hd-games-backend" = "yes"
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 60
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    ####
    schedules = {
        scale-up = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  /*"vn-lumi-uat-eks-dm1" = {
    name            = "vn-lumi-uat-eks-dm1"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes",
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "gn-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "gn-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "gn-games-backend" = "yes"
            "sp-api" = "yes"
            "sp-games" = "yes"
            "sp-games-backend" = "yes"
            "sk-api" = "yes"
            "sk-games" = "yes"
            "sk-games-backend" = "yes"
            "tg-api" = "yes"
            "tg-games" = "yes"
            "tg-games-backend" = "yes"
            "hd-api" = "yes"
            "hd-games" = "yes"
            "hd-games-backend" = "yes"
            "node-role.kubernetes.io/web" = "true"
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 80
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "ON_DEMAND"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    ####
    schedules = {
        scale-up = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  ############## SENTRY
  /*
  "vn-lumi-uat-eks-sp8" = {
    name            = "vn-lumi-uat-eks-sp8"
    subnet_ids = ["subnet-0ae72c2068513e76b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
            "sentry" = "yes",
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3.2xlarge",
      "t3a.2xlarge"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 40
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            delete_on_termination = true
          }
        }
      }
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tag_specifications = [
      "instance",
      "volume",
      "network-interface"
    ]
    ####
    schedules = {
      scale-up = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "10 08 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        yum install nfs-utils -y
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  */
}

###############
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.21.0"
spot_termination_handler_chart_namespace = "kube-system"

###############
namespaces = ["haproxy","sample","nexops"]
###############
admin_users     = ["tf.josh.tran","tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
