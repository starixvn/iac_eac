environment                     = "dr"
project                         = "vn"
dept                            = "VNTeam"
team                            = "NX-Pentagon"
function                        = "v1"
aws_region                      = "ap-southeast-1"
aws_region_bucket_remote_state  = "vn-lumi-starix-tf-state"
aws_region_key_iam_remote_state = "env:/dr/lumi-iam-tf.tfstate"
allow_whitelist                 = ["202.78.231.32/27", "120.72.109.32/29", "120.72.83.128/29", "43.198.255.129/32"]
allow_cidr_block_internal       = ["10.100.252.0/25", "10.100.253.0/25", "10.100.253.128/26", "10.100.253.192/26", "10.101.0.0/20", "10.101.16.0/20", "10.101.32.0/20", "10.101.48.0/21", "10.101.56.0/21", "10.101.64.0/21"]
vpc_id                          = "vpc-0080458809d79b6f8"
lb_subnets                      = "subnet-07dafae09b15e130a\\,subnet-0fe68c8b5f66016ee\\,subnet-0e7697ed6216c590e"
lb_az_cross                     = "true"
create_cloudwatch_log_group     = "false"
#lb_private_ips = "10.88.112.250\\,10.88.143.250\\,10.88.159.250"
vpc_private_subnets = [
  "subnet-07dafae09b15e130a",
  "subnet-0fe68c8b5f66016ee",
  "subnet-0e7697ed6216c590e"
]
#   "subnet-07dafae09b15e130a", 10.101.72.0/21 (2046): 10.101.72.1 → 10.101.79.254
#   "subnet-0fe68c8b5f66016ee", 10.101.80.0/21 (2046): 10.101.80.1 → 10.101.87.254
#   "subnet-0e7697ed6216c590e" 10.101.88.0/21 (2046): 10.101.88.1 → 10.101.95.254

autoscaling_average_cpu = 90
cluster_version         = "1.33"
eks_managed_node_groups = {
  ######## HAPROXY Ingress
  "nx-pentagon-dr-ing1" = {
    name                       = "nx-pentagon-dr-ing1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-07dafae09b15e130a"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "haproxy" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
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
          volume_size           = 20
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
    schedules = {}
    cloudinit_pre_nodeadm = [
      {
        content_type = "text/x-shellscript"
        content      = <<-EOT
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
          EOT
      },
      {
        content_type = "application/node.eks.aws"
        content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "nx-pentagon-dr-ing2" = {
    name                       = "nx-pentagon-dr-ing2"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0fe68c8b5f66016ee"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "haproxy" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
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
          volume_size           = 20
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
    schedules = {}
    cloudinit_pre_nodeadm = [
      {
        content_type = "text/x-shellscript"
        content      = <<-EOT
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
          EOT
      },
      {
        content_type = "application/node.eks.aws"
        content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ####NexOps Monitor
  "nx-pentagon-dr-mon1" = {
    name                       = "nx-pentagon-dr-mon1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0fe68c8b5f66016ee"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "nexops-mon" = "yes"
      "nexops"     = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6i.large",
      "t3a.large",
      "t3.large",
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
    schedules = {}
    cloudinit_pre_nodeadm = [
      {
        content_type = "text/x-shellscript"
        content      = <<-EOT
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
          EOT
      },
      {
        content_type = "application/node.eks.aws"
        content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ######## APP ON DEMAND
  "nx-pentagon-dr-dm1" = {
    name                       = "nx-pentagon-dr-dm1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
      {
        content_type = "text/x-shellscript"
        content      = <<-EOT
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
          EOT
      },
      {
        content_type = "application/node.eks.aws"
        content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
}
/*
  ######## APP ON DEMAND
  "nx-pentagon-dr-dm1" = {
    name                       = "nx-pentagon-dr-dm1"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
          {
            content_type = "text/x-shellscript"
            content      = <<-EOT
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
          EOT
          },
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  
  "nx-pentagon-dr-dm2" = {
    name                       = "nx-pentagon-dr-dm2"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
          {
            content_type = "text/x-shellscript"
            content      = <<-EOT
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
          EOT
          },
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-dr-dm3" = {
    name                       = "nx-pentagon-dr-dm3"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
          {
            content_type = "text/x-shellscript"
            content      = <<-EOT
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
          EOT
          },
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-dr-dm4" = {
    name                       = "nx-pentagon-dr-dm4"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
          {
            content_type = "text/x-shellscript"
            content      = <<-EOT
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
          EOT
          },
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-dr-dm5" = {
    name                       = "nx-pentagon-dr-dm5"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/nx-pentagon-dr-cloudwatch-policy-v1"
    }
    labels = {
      "luminet-app"       = "yes",
      "sc1-games"         = "yes"
      "sc2-games"         = "yes"
      "gn-games"          = "yes"
      "sc1-api"           = "yes"
      "sc2-api"           = "yes"
      "gn-api"            = "yes"
      "sc1-games-backend" = "yes"
      "sc2-games-backend" = "yes"
      "gn-games-backend"  = "yes"
      "sp-api"            = "yes"
      "sp-games"          = "yes"
      "sp-games-backend"  = "yes"
      "sk-api"            = "yes"
      "sk-games"          = "yes"
      "sk-games-backend"  = "yes"
      "tg-api"            = "yes"
      "tg-games"          = "yes"
      "tg-games-backend"  = "yes"
      "hd-api"            = "yes"
      "hd-games"          = "yes"
      "hd-games-backend"  = "yes"
      "nexops"            = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 2
    desired_size = 1
    instance_types = [
      "t3a.large",
      "t3.large"
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
    schedules = {}
    cloudinit_pre_nodeadm = [
          {
            content_type = "text/x-shellscript"
            content      = <<-EOT
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
          EOT
          },
          {
            content_type = "application/node.eks.aws"
            content      = <<-EOT
            ---
            apiVersion: node.eks.aws/v1alpha1
            kind: NodeConfig
            spec:
              cluster:
                apiServerEndpoint: https://B591EA77A7679676565B45BEF979F1A0.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJRHg0R0c5STlzREF3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFd016RXdOalE1TURWYUZ3MHpOVEV3TWprd05qVTBNRFZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNuSG5ZRS9BVEtCMWMyamZRTk1WbDhXTzRkaG9SYk9xdWpVWjhTb0ZhSExaWFdPVk8rTEZMc09UY0oKcHNOYnpYQ2JWVFpzTlV2MkFDU3VieXlXVkYwS0hsUTdDTDRpRGlCMlRkYUVnaWhlY21kcXBXTlpuU1BQMDAzVQphQmVrcW5FQ0pSdldneUsrOE56bUNycXpIMzBCWHQyREFIUyt4Z3NkNG9BbEY1cDBWVkxlVk82L0srTlNOVDJiCkFqeWJBUFdqbTQzaGxsQmMxQmRuWjNxOHBJbW5GZmE4a2pTbi9wNE9oMkM3cTdSSFV3aDN2SVpyR25iNTB4dzQKZVVGSGxwdjhVTmN0UVNodEN2dFdJOHA3aFpSaUhYSVF3R3lUcytvb0JrbmVMMkFmZ0czRFhqVUhzYjhJT2lGbgp0VStxS0Uwa0d1R1dYdnpvVHY1Zk9PSzQ5YnIzQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTQ2lFeUJJMkFkN3lrK3JUcTExOTBMSUQ4Y0N6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmxRMVpyeUZOVgpRSG9hQkE1OFU0c2NGR1k2TXpuczdTaVdzNDFDS0xwaHpWTjVydHFpWEl6MjBoRUJJS0krYnBQWHJXTkM2c3ZBCnRsVzBVM2FzNXc5dW9lNnJRRmFVQlFQRzhPVW1nUFZXVUdFTmlHZW9HN2hRM29XLyt3WWllSmJma0pkK25PbEQKOFhlbXFlTUhvRnplc2ZXVzAzVjh6Ulp0OUUzQlhTeVJCTXNxS1J5MTI2KzZJSDk2ckJtTmNWcWNic0VnZUZTMgpNTGlBWGVHbTA0czJFUEZ3d1dvc0oyNWV3c2hKbWZ0MnIvdTFmbzhlNktla2JWdXIzamRXMURtTTF3U0ZKdS9pCjY0QnB1SkpRdFZ1K2VVZUFNR082Nk12cFBNQ3pHUE1mQjBQNHZPREZvUjU3RWdQS3hJZm93UGdrZ1NyMXJMSWUKT2JvbjMvY1g4ZkNrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1dr-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
*/

###############
namespaces = ["sample", "nexops"]
###############
admin_users     = ["tf.josh.tran", "tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
