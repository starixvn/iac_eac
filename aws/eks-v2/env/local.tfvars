project = "cloud"
team = "Lumi"
aws_region = "ap-east-1"
environment = "local"
aws_profile = "local-iac-terraform-ci"
aws_region_bucket_remote_state = "cloud-lumi-starix-tf-goshawk"
aws_region_key_remote_state    = "env:/local/vpc-terraform.tfstate"
aws_region_key_iam_remote_state = "env:/local/lumi-iam-tf.tfstate"
aws_region_bucket_remote_state_vn = "cloud-lumi-starix-tf-goshawk"

allow_whitelist = ["202.78.231.32/27","120.72.109.32/29","120.72.83.128/29"]
allow_cidr_block_internal = ["10.6.0.0/16"]
create_cloudwatch_log_group = "false"
vpc_id = "vpc-039a936178b304105"
lb_subnets = "subnet-06fe4c10600cb02db\\,subnet-01667b309462c88dd\\,subnet-00da5f1187472fb52"
lb_az_cross = "true"
vpc_private_subnets = [
  "subnet-06fe4c10600cb02db",
  "subnet-01667b309462c88dd",
  "subnet-00da5f1187472fb52"
]
####
cluster_version = "1.28"
autoscaling_average_cpu = 80
eks_managed_node_groups = {
  "lumi-eks-spot1" = {
    name            = "lumi-eks-app1-spot"
    subnet_ids = ["subnet-06fe4c10600cb02db"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::584102114761:policy/lumi-local-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes"
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "haproxy" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3.large",
      "m5.large",
      "c5.large",
      "c5a.large",
      "c5.xlarge",
      "c5a.xlarge"
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
          recurrence   = "00 19 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  "lumi-eks-spot2" = {
    name            = "lumi-eks-app2-spot"
    subnet_ids = ["subnet-06fe4c10600cb02db"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::584102114761:policy/lumi-local-cloudwatch-policy-v1"
    }
    labels = {
            "luminet-app" = "yes"
            "sc1-games" = "yes"
            "sc2-games" = "yes"
            "sc1-api" = "yes"
            "sc2-api" = "yes"
            "sc1-games-backend" = "yes"
            "sc2-games-backend" = "yes"
            "haproxy" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3.large",
      "m5.large",
      "c5.large",
      "c5a.large",
      "c5.xlarge",
      "c5a.xlarge"
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
          recurrence   = "00 19 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },

  "lumi-eks-spot3" = {
    name            = "lumi-eks-elk1-spot"
    subnet_ids = ["subnet-06fe4c10600cb02db"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::584102114761:policy/lumi-local-cloudwatch-policy-v1"
    }
    labels = {
            "nexops-logs" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3.large",
      "m5.large",
      "c5.large",
      "c5a.large",
      "c5.xlarge",
      "c5a.xlarge"
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
          recurrence   = "59 23 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },

    "lumi-eks-spot4" = {
    name            = "lumi-eks-elk2-spot"
    subnet_ids = ["subnet-06fe4c10600cb02db"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::584102114761:policy/lumi-local-cloudwatch-policy-v1"
    }
    labels = {
            "nexops-logs" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3.large",
      "m5.large",
      "c5.large",
      "c5a.large",
      "c5.xlarge",
      "c5a.xlarge"
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
          recurrence   = "59 23 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },

}

###############
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.21.0"
spot_termination_handler_chart_namespace = "kube-system"

###############
namespaces = ["haproxy","sample","nexops"]
###############
admin_users     = ["ken.nguyen","dennis.le","troy.vo"]
developer_users = ["dev1", "dev2"]
