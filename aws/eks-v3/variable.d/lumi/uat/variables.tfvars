environment = "uat"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state = "vn-lumi-starix-tf-state"
aws_region_key_iam_remote_state = "env:/uat/lumi-iam-tf.tfstate"
allow_whitelist = ["202.78.231.32/27","120.72.109.32/29","120.72.83.128/29","43.198.255.129/32"]
allow_cidr_block_internal = ["10.100.252.0/25","10.100.253.0/25","10.100.253.128/26","10.100.253.192/26","10.101.0.0/20","10.101.16.0/20","10.101.32.0/20","10.101.48.0/21","10.101.56.0/21","10.101.64.0/21"]
vpc_id = "vpc-0080458809d79b6f8"
lb_subnets = "subnet-0a4e02d5e2193e3cf\\,subnet-0108d53b24f4083e4\\,subnet-0b6ab739f6da6a762"
lb_az_cross = "true"
create_cloudwatch_log_group = "false"
#lb_private_ips = "10.88.112.250\\,10.88.143.250\\,10.88.159.250"
vpc_private_subnets = [
  "subnet-0a4e02d5e2193e3cf",
  "subnet-0108d53b24f4083e4",
  "subnet-0b6ab739f6da6a762"
]
#   "subnet-0a4e02d5e2193e3cf", 10.101.0.0/20 (4k): 10.101.0.1->10.101.15.254
#   "subnet-0108d53b24f4083e4", 10.101.16.0/20 (4k): 10.101.16.1->10.101.31.254 
#   "subnet-0b6ab739f6da6a762" 10.101.32.0/20 (4k): 10.101.32.1->10.101.47.254
autoscaling_average_cpu = 90
cluster_version = "1.33"
eks_managed_node_groups = {
  /*
  ######### HAPROXY Ingress
  "vn-lumi-uat-eks-ing1" = {
    name            = "vn-lumi-uat-eks-ing1"
    subnet_ids = ["subnet-0a4e02d5e2193e3cf"]
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
        scale-up = {
          min_size     = 0
          max_size     = 1
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = 1
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=110/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  */
######## APP SPOT
  "nx-pentagon-uat-sp1" = {
    name            = "nx-pentagon-uat-sp1"
    key_name        = "vnteam"
    subnet_ids = ["subnet-0a4e02d5e2193e3cf"]
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

    #ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge",
      "m6i.large",
      "m6i.xlarge",
      "m6i.2xlarge",
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
          max_size     = 1
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = 1
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        PROXY=infra-proxy.vpcbukittimah.com:8801
        TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
        MAC=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/mac/)
        VPC_CIDR=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-blocks | xargs | tr ' ' ',')
        mkdir -p /etc/systemd/system/containerd.service.d
        mkdir -p /etc/systemd/system/sandbox-image.service.d
        cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
        proxy=http://$PROXY
        EOF
        cloud-init-per instance proxy_config cat << EOF >> /etc/environment
        http_proxy=http://$PROXY
        https_proxy=http://$PROXY
        HTTP_PROXY=http://$PROXY
        HTTPS_PROXY=http://$PROXY
        no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        EOF
        cloud-init-per instance containerd_proxy_config tee <<EOF /etc/systemd/system/containerd.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance sandbox-image_proxy_config tee <<EOF /etc/systemd/system/sandbox-image.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
        [Service]
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance reload_daemon systemctl daemon-reload
        curl -o /etc/pki/ca-trust/source/anchors/rootCAgamora.pem  https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgamora.crt && update-ca-trust
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  "nx-pentagon-uat-sp5" = {
    name            = "nx-pentagon-uat-sp5"
    key_name        = "vnteam"
    subnet_ids = ["subnet-0a4e02d5e2193e3cf"]
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

    #ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge",
      "m6i.large",
      "m6i.xlarge",
      "m6i.2xlarge",
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
          max_size     = 1
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = 1
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        PROXY=infra-proxy.vpcbukittimah.com:8801
        TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
        MAC=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/mac/)
        VPC_CIDR=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-blocks | xargs | tr ' ' ',')
        mkdir -p /etc/systemd/system/containerd.service.d
        mkdir -p /etc/systemd/system/sandbox-image.service.d
        cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
        proxy=http://$PROXY
        EOF
        cloud-init-per instance proxy_config cat << EOF >> /etc/environment
        http_proxy=http://$PROXY
        https_proxy=http://$PROXY
        HTTP_PROXY=http://$PROXY
        HTTPS_PROXY=http://$PROXY
        no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        EOF
        cloud-init-per instance containerd_proxy_config tee <<EOF /etc/systemd/system/containerd.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance sandbox-image_proxy_config tee <<EOF /etc/systemd/system/sandbox-image.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
        [Service]
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance reload_daemon systemctl daemon-reload
        curl -o /etc/pki/ca-trust/source/anchors/rootCAgamora.pem  https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgamora.crt && update-ca-trust
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
  "nx-pentagon-uat-sp2" = {
    name            = "nx-pentagon-uat-sp2"
    key_name        = "vnteam"
    subnet_ids = ["subnet-0a4e02d5e2193e3cf"]
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

    #ami_type     = "AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large",
      "t3.2xlarge",
      "t3a.2xlarge",
      "m6i.large",
      "m6i.xlarge",
      "m6i.2xlarge",
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
          max_size     = 1
          desired_size = 1
          time_zone    = "Asia/Bangkok"
          recurrence   = "30 07 * * MON-FRI"
        },
        scale-down = {
          min_size     = 0
          max_size     = 1
          desired_size = 0
          time_zone    = "Asia/Bangkok"
          recurrence   = "00 20 * * MON-FRI"
        }
      }
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        PROXY=infra-proxy.vpcbukittimah.com:8801
        TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
        MAC=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/mac/)
        VPC_CIDR=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/vpc-ipv4-cidr-blocks | xargs | tr ' ' ',')
        mkdir -p /etc/systemd/system/containerd.service.d
        mkdir -p /etc/systemd/system/sandbox-image.service.d
        cloud-init-per instance yum_proxy_config cat << EOF >> /etc/yum.conf
        proxy=http://$PROXY
        EOF
        cloud-init-per instance proxy_config cat << EOF >> /etc/environment
        http_proxy=http://$PROXY
        https_proxy=http://$PROXY
        HTTP_PROXY=http://$PROXY
        HTTPS_PROXY=http://$PROXY
        no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod
        EOF
        cloud-init-per instance containerd_proxy_config tee <<EOF /etc/systemd/system/containerd.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance sandbox-image_proxy_config tee <<EOF /etc/systemd/system/sandbox-image.service.d/http-proxy.conf >/dev/null
        [Service]    
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance kubelet_proxy_config tee <<EOF /etc/systemd/system/kubelet.service.d/proxy.conf >/dev/null
        [Service]
        EnvironmentFile=/etc/environment
        EOF
        cloud-init-per instance reload_daemon systemctl daemon-reload
        curl -o /etc/pki/ca-trust/source/anchors/rootCAgamora.pem  https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgamora.crt && update-ca-trust
        LINE_NUMBER=$(grep -n "KUBELET_EXTRA_ARGS=\$2" /etc/eks/bootstrap.sh | cut -f1 -d:)
        REPLACEMENT="\ \ \ \ \ \ KUBELET_EXTRA_ARGS=\$(echo \$2 | sed -s -E 's/--max-pods=[0-9]+/--max-pods=200/g')"
        sed -i '/KUBELET_EXTRA_ARGS=\$2/d' /etc/eks/bootstrap.sh
        sed -i "$${LINE_NUMBER}i $${REPLACEMENT}" /etc/eks/bootstrap.sh
      EOT
  },
}

###############
namespaces = ["sample","nexops"]
###############
admin_users     = ["tf.josh.tran","tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
