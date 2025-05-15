project = "clouddemo"
team = "Lumi"
aws_region = "ap-northeast-1"
environment = "testlab"
aws_profile = "test-iac-terraform-ci"
aws_region_bucket_remote_state = "clouddemo-lumi-starix-tf-terrapin"
aws_region_key_remote_state    = "env:/testlab/vpc-terraform.tfstate"
allow_whitelist = ["202.78.231.32/27","120.72.109.32/29","120.72.83.128/29"]
lb_subnets = "subnet-04510efa6d218ba22\\,subnet-0298ca5ea219cc74f\\,subnet-06b24b20b5e0bfa35"
lb_az_cross = "true"
allow_cidr_block_internal = ["10.6.0.0/16"]
vpc_id = "vpc-02ddfbd7054475e00"
vpc_private_subnets = [
  "subnet-04510efa6d218ba22",
  "subnet-0298ca5ea219cc74f",
  "subnet-06b24b20b5e0bfa35"
]
####
###############
namespaces = ["haproxy","sample","nexops"]
###############
admin_users     = ["ken.test", "troy.test"] #, "troy.vo"
developer_users = ["dev1", "dev2"]

autoscaling_average_cpu = 90
cluster_version = "1.27"
eks_managed_node_groups = {
  
######## APP SPOT
  "vn-lumi-lab-eks-sp1" = {
    name            = "vn-lumi-lab-eks-sp1"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = true

    labels = {
            "luminet-app" = "yes",
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.medium",
      "t3.medium",
      "t2.medium",
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
          recurrence   = "00 08 * * MON-FRI"
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
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  ######## APP ON DEMAND
  "vn-lumi-lab-eks-dm1" = {
    name            = "vn-lumi-lab-eks-dm1"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = true

    labels = {
            "luminet-app" = "yes",
            "nexops" = "yes"
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
            volume_size           = 40
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
          recurrence   = "00 08 * * MON-FRI"
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
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=150/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
    #enable_bootstrap_user_data = true
    #bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=110'"
  },
  
}
/*eks_managed_node_groups = {
  "lumi-eks-on_demand-arm" = {
    name            = "lumi-eks-demand-x86"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    remote_access = {
      ec2_ssh_key = "eks-terraform-key"
    }
    use_custom_launch_template = false
    labels = {
            "luminet-app" = "yes",
            "nexops" = "yes",
            "haproxy" = "yes",
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    disk_size = 30
    instance_types = [
      "t3a.small"
    ]
    capacity_type = "ON_DEMAND"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    enable_bootstrap_user_data = true
    bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=110'"
  },
 "lumi-eks-spot-x86" = {
    name            = "lumi-eks-spot-x86"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = false
    remote_access = {
      ec2_ssh_key = "eks-terraform-key"
    }
    labels = {
            "luminet-app" = "yes",
            "nexops" = "yes",
            "haproxy" = "yes",
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    disk_size = 30
    instance_types = [
      "t3a.small",
      "t3.small"
    ]
    capacity_type = "SPOT"
    network_interfaces = [{
      delete_on_termination       = true
      associate_public_ip_address = false
    }]
    tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    enable_bootstrap_user_data = true
    bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--max-pods=110'"
  }
}
*/
/*
"lumi-eks-spot-x86" = {
    name            = "lumi-eks-spot-x86"
    subnet_ids = ["subnet-0d3cd100ba5d9dc9d"]
    use_custom_launch_template = true
    labels = {
            "luminet-app" = "yes"
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
            volume_size           = 15
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
          start_time   = "2023-11-01T09:00:00Z"
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 08 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          start_time   = "2023-11-01T08:50:00Z"
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 18 * * MON-FRI"
        }
      }
  }

    remote_access = {
      ec2_ssh_key = "eks-terraform-key"
    }
*/
###############
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.21.0"
spot_termination_handler_chart_namespace = "kube-system"



/*
eks_managed_node_groups = {
  "lumi-lab-ingress" = {
    name            = "lumi-lab-eks-ingress"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = true

    labels = {
            "haproxy" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.small",
      "t3a.medium"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 10
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
        
      }
  },
  "lumi-lab-gr1" = {
    name            = "lumi-lab-eks-demand"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = true

    labels = {
            "luminet-app" = "yes",
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.medium",
      "t3.medium"
    ]
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 10
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
          recurrence   = "00 08 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "55 16 * * MON-FRI"
        }
      }
  },
  "lumi-lab-gr2" = {
    name            = "lumi-lab-eks-spot"
    subnet_ids = ["subnet-04510efa6d218ba22"]
    use_custom_launch_template = true

    labels = {
            "luminet-app" = "yes",
            "nexops" = "yes"
          }

    ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.medium",
      "t3.medium"
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
          recurrence   = "00 08 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = "1" # Retains current max size
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 19 * * MON-FRI"
        }
      }
  },
}
*/