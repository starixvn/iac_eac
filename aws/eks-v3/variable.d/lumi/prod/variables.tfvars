environment = "prod"
project = "vn"
team = "NX-Pentagon"
aws_region  = "ap-southeast-1"
aws_region_bucket_remote_state = "vn-lumi-starix-tf-state"
aws_region_key_iam_remote_state = "env:/prod/lumi-iam-tf.tfstate"
allow_whitelist = ["202.78.231.32/27","120.72.109.32/29","120.72.83.128/29","43.198.255.129/32"]
allow_cidr_block_internal = ["10.100.252.0/25","10.100.253.0/25","10.100.253.128/26","10.100.253.192/26","10.101.0.0/20","10.101.16.0/20","10.101.32.0/20","10.101.48.0/21","10.101.56.0/21","10.101.64.0/21"]
vpc_id = "vpc-0080458809d79b6f8"
lb_subnets = "subnet-0613fbd221a805b5b\\,subnet-013bce3c7a2d4020c\\,subnet-0475b4fa8ffc80ab7"
lb_az_cross = "true"
create_cloudwatch_log_group = "false"
#lb_private_ips = "10.88.112.250\\,10.88.143.250\\,10.88.159.250"
vpc_private_subnets = [
  "subnet-0613fbd221a805b5b",
  "subnet-013bce3c7a2d4020c",
  "subnet-0475b4fa8ffc80ab7"
]
#   "subnet-0613fbd221a805b5b", 10.101.48.0/21 (2046): 10.101.48.1->10.101.55.254
#   "subnet-013bce3c7a2d4020c", 10.101.56.0/21 (2046): 10.101.56.1->10.101.63.254
#   "subnet-0475b4fa8ffc80ab7" 10.101.64.0/21(2046): 10.101.64.1->10.101.71.254

autoscaling_average_cpu = 90
cluster_version         = "1.33"
eks_managed_node_groups = {
  ######## NexOps tools
  "nx-pentagon-prod-eks-awx" = {
    name                       = "nx-pentagon-prod-awx"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
      "nexops" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD" #"AL2_x86_64"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.xlarge",
      "t3.xlarge",
      "t3.2xlarge",
      "t3a.2xlarge",
      "m6i.xlarge",
      "m6i.2xlarge",
    ]
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 50
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
          }
      ]
  },
  "nx-pentagon-prod-eks-hub" = {
    name                       = "nx-pentagon-prod-hub"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
      "nexops" = "yes"
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
          volume_size           = 50
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-mon1" = {
    name                       = "nx-pentagon-prod-mon1"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
      "nexops-mon" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
      "t3a.xlarge",
      "t3.xlarge",
      "m6i.xlarge",
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  ######## HAPROXY Ingress
  "nx-pentagon-prod-ing1" = {
    name                       = "nx-pentagon-prod-ing1"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
      "haproxy" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-ing2" = {
    name                       = "nx-pentagon-prod-ing2"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
    }
    labels = {
      "haproxy" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 0
    max_size     = 1
    desired_size = 1
    instance_types = [
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  ######## APP ON DEMAND
  "nx-pentagon-prod-dm1" = {
    name                       = "nx-pentagon-prod-dm1"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
      "t3a.medium",
      "t3.medium"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  
  "nx-pentagon-prod-dm2" = {
    name                       = "nx-pentagon-prod-dm2"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
      "t3a.medium",
      "t3.medium"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-dm3" = {
    name                       = "nx-pentagon-prod-dm3"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-0613fbd221a805b5b"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
      "t3a.medium",
      "t3.medium"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-dm4" = {
    name                       = "nx-pentagon-prod-dm4"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
      "t3a.medium",
      "t3.medium"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-dm5" = {
    name                       = "nx-pentagon-prod-dm5"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
      "t3a.medium",
      "t3.medium"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
  "nx-pentagon-prod-dm6" = {
    name                       = "nx-pentagon-prod-dm6"
    key_name        = "vnteam"
    subnet_ids                 = ["subnet-013bce3c7a2d4020c"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-prod-cloudwatch-policy-v1"
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
                apiServerEndpoint: https://F74006CA89D990C1B0BAF42607B51B47.gr7.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJT3hRTXFKbzFRV0l3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1EWXdOekExTURKYUZ3MHpOVEEyTURRd056RXdNREphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURXdmNpeWdTcVEwMnQxbGlkaUVoOFNsb3dJaVJVb3pGSGxJaHg1YVRxZE9wR25FTWZVZVpxOWdja0cKMkdSQ0ZLc3RXSFpxbDcwMWZvUUJZS2tVbDlUWEd2TlU4bEVRbEU0S0xGOXBveWkwa3ZTNTJ3TkZvSGp1WmtJVgp0MGdYS1FUZ0MvY05STThLTHJhV2J6RXpJRW4zUDJiMG04Ym50TXNNTWtQTHNhUmhEZlV5WGRyNXpkMmFPRFFPCm5zKzVqM0NjdzNrMUNDQTh2U3lIZXg5cUdDQUJnOWtPMDRwYWtNOFlWaWZlNEZrT1I2N1E0K1l0d0ExTm0vc2oKSlE4K2NNSGNhcWxWVmovZ1Nsc1Ixa3h0TkVYdWN4YXNKRWJzOFgwZnY2eWVkWlREclJMODM3bEFRTklRUjNVMQpCOSsxRUY1cFFtNXQ4K0VMb2RJS3c5cFVPTW9qQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVUtlVkN3TkhhVnFVcndpSmljaEtLR0IwQmNUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1hEWVdoTm1TMgpMWEtDVFMyMnpUQXA4Vk1XOWM2aDk5U1M2dE9KeW0zMkorc2o2SCtOQm04aUREU0pZMEFzcmV6ekNCb3d3TDgrClJQNUJ1YkMwL1ZqTk40WEZuc3Mvdk95ejM5NzdGRXJ2cWw3NGJ6aEM5Mk5LOFRMTFJjbG1VSk1CKzhFbXQwZFcKalIvdVVhOUNzaVhjdERQMlBIeGE3aURaenBRaDhuQ2VUUFd1MG1ydm9yZlVNOTQ3c1lqMTMvbWw4UW1nNi85Sgo3NHN5c0tnK2JaaEIzMVpQM01JejhxaC9KUlN6L3A5ckdTN3hxUHZHQ1lrT0VJTzZEMHJvY0pzeXFVL25sNUViCnhtMkF5U0o1N3ZPcXpSMHlNWlN5bThRU0tNbEwrNVU5Ykovb3RWUGdZZlhxazVleFVqa0sxa2gzR0RTUzFXangKekx0Sk9vSXRyVjRkCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1prod-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
          }
      ]
  },
}

###############
namespaces = ["sample", "nexops"]
###############
admin_users     = ["tf.josh.tran", "tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
