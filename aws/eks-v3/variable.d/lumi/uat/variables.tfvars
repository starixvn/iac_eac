environment                     = "uat"
project                         = "vn"
team                            = "NX-Pentagon"
aws_region                      = "ap-southeast-1"
aws_region_bucket_remote_state  = "vn-lumi-starix-tf-state"
aws_region_key_iam_remote_state = "env:/uat/lumi-iam-tf.tfstate"
allow_whitelist                 = ["202.78.231.32/27", "120.72.109.32/29", "120.72.83.128/29", "43.198.255.129/32"]
allow_cidr_block_internal       = ["10.100.252.0/25", "10.100.253.0/25", "10.100.253.128/26", "10.100.253.192/26", "10.101.0.0/20", "10.101.16.0/20", "10.101.32.0/20", "10.101.48.0/21", "10.101.56.0/21", "10.101.64.0/21"]
vpc_id                          = "vpc-0080458809d79b6f8"
lb_subnets                      = "subnet-0a4e02d5e2193e3cf\\,subnet-0108d53b24f4083e4\\,subnet-0b6ab739f6da6a762"
lb_az_cross                     = "true"
create_cloudwatch_log_group     = "false"
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
cluster_version         = "1.33"
eks_managed_node_groups = {
  ######### HAPROXY Ingress
  "nx-pentagon-uat-ing1" = {
    name                       = "nx-pentagon-uat-ing1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
      "haproxy" = "yes"
    }
    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 2
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ####NexOps Monitor
  "nx-pentagon-uat-mon1" = {
    name                       = "nx-pentagon-uat-mon1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
    }
    labels = {
      "nexops-mon" = "yes"
      "nexops"     = "yes"
    }

    ami_type     = "AL2023_x86_64_STANDARD"
    min_size     = 1
    max_size     = 2
    desired_size = 1
    instance_types = [
      #"m6i.large",
      "m6i.xlarge",
      #"t3a.large",
      "t3a.xlarge",
      #"t3.large",
      "t3.xlarge",
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  ######## APP SPOT
  "nx-pentagon-uat-sp1" = {
    name                       = "nx-pentagon-uat-sp1"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
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
    min_size     = 1
    max_size     = 2
    desired_size = 1
    instance_types = [
      "m6i.large",
      "m6i.xlarge",
      "t3a.large",
      "t3a.xlarge",
      "t3.large",
      "t3.xlarge",
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "nx-pentagon-uat-sp2" = {
    name                       = "nx-pentagon-uat-sp2"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
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
    min_size     = 1
    max_size     = 2
    desired_size = 1
    instance_types = [
      "m6i.large",
      "m6i.xlarge",
      "t3a.large",
      "t3a.xlarge",
      "t3.large",
      "t3.xlarge",
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "nx-pentagon-uat-sp3" = {
    name                       = "nx-pentagon-uat-sp3"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
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
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6i.large",
      "m6i.xlarge",
      "t3a.large",
      "t3a.xlarge",
      "t3.large",
      "t3.xlarge",
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
              kubelet:
                config:
                    maxPods: 200
          EOT
      }
    ]
  },
  "nx-pentagon-uat-sp4" = {
    name                       = "nx-pentagon-uat-sp4"
    key_name                   = "vnteam"
    subnet_ids                 = ["subnet-0a4e02d5e2193e3cf"]
    use_custom_launch_template = true
    iam_role_additional_policies = {
      additional = "arn:aws:iam::014999276089:policy/lumi-uat-cloudwatch-policy-v1"
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
    min_size     = 1
    max_size     = 1
    desired_size = 1
    instance_types = [
      "m6i.large",
      "m6i.xlarge",
      "t3a.large",
      "t3a.xlarge",
      "t3.large",
      "t3.xlarge",
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
                apiServerEndpoint: https://E6191EEBBB4840436E79DD857495912F.yl4.ap-southeast-1.eks.amazonaws.com
                certificateAuthority: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJUWFnQ0JTWDN2Vnd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBMk1Ea3dPRFV5TUROYUZ3MHpOVEEyTURjd09EVTNNRE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURuQnVYUUpVd3VpdTZrUHloYUVnYkJVTTdUZFdleEE1cVp4SCswL3A5QWpsTUlNYk4wMDRaSEtWRisKM20vZUwyUFFMdHVqMFl2dXM3YjVyUG5QWHZDNWN1dnRXRXQ0OWpkRWh5Q3FxQ0J2TE1lVUN1SkxhMjNOWmd4Zgpyam1uTWQ4UWJUSEdGa3QxTEtNcXB3LzBxb0VFOE1SNFBMNWdJRHJOZGV5OWw3TTROVHJwL2lqUW82SVErSmcrCkhJUTdNZEpYYUhsVW5LTE1YWlVIT2pUSUJNRE8zeWVNSEk4RFNpUlpFem1VVmRLOTYzVXpoREJRZ2Nkd3M3RkUKMHQ3Tzl5bTArekxtVVAzenQ1YnR0UGcxQ3lGYUx6dEpXTzd5Uy9NZnFrWE5Yc1RxRjZwWWNqZzVSU2d6S0JLLwpTSUpnNG9LNGRhanlKaFdtVkQzem9UOVlSem1sQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTbXMzSDZtcHo2SC85b0pTQkd5RHdjZ2srOFBUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQzlnYXhxR1l5SgovSDhIOGUxYUtLZ2RKMVpySU5kUUtzTzdKN3piTVdYcjdwaXNCWDdTZHZXQllkSzc4M25VWUZQWlltUklCbkFaCndvL1lkeTVjZ1NNOHFCNVBUNzR1TW04MHFWdVQ2dnNlVHczbS9iVHhVQ0ZiWmluTFNMZXBiZHJIZ2t4TUxibHQKa2FFZEF3cXdWQ0dwdUtlbTkvNlRMQWFHNnVzK0p6UWVsdkw0dno5R1M2ancrOW1MUUVrWEJrTU9PNE5KdUZYaApMTzh0RVl2d04wZ1BRNVUxK2I2MTcza2VDakd5YktVbVIycG1hYldhME5KNkVROFdQcnJTdzMrWUswRmRlelhGClpHUWtCbFBhY2VybzhQNS90VVBsSkZyeXFDbmk0RUVoQXVJUDEzamNEcU5IRVJPbFhsYVVkMnhKRHpYMlZLZHoKMGJDeVpQRk10LzZiCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
                cidr: 10.100.0.0/16
                name: nx-pentagon-t1uat-v1
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
