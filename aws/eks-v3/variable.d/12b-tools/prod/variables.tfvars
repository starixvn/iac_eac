environment                     = "prod"
project                         = "AT"
dept                            = "VNTeam"
team                            = "12B"
function                        = "inhouse-tools"
aws_region                      = "ap-northeast-1"
aws_region_bucket_remote_state  = "at-tf-state-s3"
aws_region_key_iam_remote_state = "env:/prod/12b-iam-tf.tfstate"
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
  ######## Ingress
  "12b-prod-rabbitmq-az1" = {
    name                       = "12b-prod-rabbitmq-az1"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-0ae4fa62cdde25537"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "rabbitmq" = "yes",
      "haproxy"  = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "12b-prod-rabbitmq-az2" = {
    name                       = "12b-prod-rabbitmq-az2"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-071344c53d872b97e"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "rabbitmq" = "yes",
      "haproxy"  = "yes",
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "12b-prod-rabbitmq-az3" = {
    name                       = "12b-prod-rabbitmq-az3"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-03e4a4b234a406be4"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "rabbitmq" = "yes",
      "haproxy"  = "yes",
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ######## NexOps tools
  "12b-prod-mon-az1" = {
    name                       = "12b-prod-mon-az1"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-0ae4fa62cdde25537"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "nexops-mon" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ######## NexPE tools
  "12b-prod-gosql-az1" = {
    name                       = "12b-prod-gosql-az1"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-0ae4fa62cdde25537"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "gosql-tools" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "12b-prod-gosql-az2" = {
    name                       = "12b-prod-gosql-az2"
    key_name                   = "strawberry-vnteam-key"
    subnet_ids                 = ["subnet-071344c53d872b97e"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::484907507662:policy/12b-prod-cloudwatch-policy-v1"
    }
    labels = {
      "gosql-tools" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6a.xlarge",
      "t3a.xlarge",
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
            PROXY=prod-infra-proxy.strawberry.com:8801
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
            no_proxy=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
            NO_PROXY=$VPC_CIDR,localhost,127.0.0.1,169.254.169.254,.internal,.eks.amazonaws.com,.gamora.prod,.strawberry.com
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
            curl -x "$PROXY" --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 2 --retry-max-time 60 -o /etc/pki/ca-trust/source/anchors/rootCAgeneral.pem "https://gitlab.starixsoft.com/nexops/ca-repo/-/raw/master/rootCAgeneral.crt" && update-ca-trust
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
                apiServerEndpoint: https://CAE3D73347B8A70FD5B1819202EDDB42.yl4.ap-northeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSGYxVlBxVlN0WU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRFeE1qZ3hORFF4TXpaYUZ3MHpOVEV4TWpZeE5EUTJNelphTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURsMjBvUkRXdjBFSGVFcW1WcWUyWVZJdERQZ01qbGxRd2lKdjBsTjJnb3VhbkxubTJRb2NvUWZNa2IKNDNtZVBiWEV6SUxFNUIvQzBBWEZ1VmRrNU8wOHZZcW5wSTd3cndCRFJsWVNBTVAxRmVMUjdZL0p0VnNrZ2w5bQoyaGgyOFN2Ylpyczl5bmgvOUViaUlKQUtobTRwK2ppM2Qva25pbTByVkJEdEQ2MlhMVWNPTEtHY0dZbW83bDZOCnR1Qnh6N2owTW9kVnZCQlErQWpnNE0wcktucDVMRWZyem9HQXg3bllGRzNnR0JxcWlXdlcwanZGQkpCZGw5dkcKZHBkNzR3U0F3UGxqOG5Dd2JxV3d5djc5dGtvNWtxc2NWVmxHMTZZYXhpSjZ2ejJsaisrbGpGczkrc29CbW1nWgp4TE5OOFBvTU5ta0dWWWh0cE83b3pIaGdpbDhQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSQVFiVjhlZTNhUVdBdDFKaElFNnBIallNQU96QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQXhCek9CcGZLUwphdithdllnUnBJSVAxK0pFdTNBNitZYVpQd0FqRnc5NzRVS2k0ZUY0aXkwVEVtUStZKzF1dGEvcktvTUVZaVVMCjhPZDQxUWpiL2NaL1MwYWszSW1TVkc4VlhBbk16dVNYdyt1Uk9uOXYyTVNEZ2JDTzFWNzVFVTdkVGk1di9nS28KODFya1k2MzJ0ck1aMHNqdG5hSmZoZytLdTJ3RzVab0pyK21hYSsrUUlBcitQTE1hZ3k2Uk1MT2REYjhzSTFqTgptY3NLdm5QZitLUWppYmxoQVZlV1NVbDFSZXBxL1B4dVltUUhaT1VzUGJBWW1WQjEzVmpDSUhLVE85dDlBbTYzCllUYTkvcHAyVlVVeXBkckhwL3N4ZVZMaTU4a0JINStjYUNrdUdUNUZ2REtKVjVrOXQxU1kzSjhTbm1MSlRYUzkKTFZPQW8rdVFtSmZxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.12.0.0/16
                name: 12b-t1prod-inhouse-tools
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
}

##################
namespaces = ["sample", "nexops"]
###############
admin_users     = ["tf.josh.tran", "tf.ken.nguyen", "tf.dennis.le", "tf.troy.vo"]
developer_users = ["dev1", "dev2"]
