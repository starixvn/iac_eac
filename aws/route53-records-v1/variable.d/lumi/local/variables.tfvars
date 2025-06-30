project                          = "cloud"
team                             = "Lumi"
aws_region                       = "ap-east-1"
environment                      = "local"
aws_profile                      = "local-iac-terraform-ci"
aws_region_bucket_remote_state   = "cloud-lumi-starix-tf-goshawk"
aws_region_key_remote_state      = "env:/local/vpc-terraform.tfstate"
aws_region_key_remote_state_zone = "env:/local/route53-tf.tfstate"
aws_region_key_remote_state_lb   = "env:/local/lumi-lb-external-tf.tfstate"

############## Route53
domain_ns_records = [
  /*{
    "zone_id" : "lumigame.com",
    "name_servers" : "staging.lumigame.com",
    "name" : "staging",
    "type" : "NS",
    "ttl" : "86400",
  },*/
]

main_records = {
  "lumigame.com" = [
    {
      # Wildcard mapping
      name   = "*",
      values = ["10.10.50.145", ]
    },
    {
      # Kube Ingress K3S-LUMPROD
      name   = "vn-sc-ing-lumprod",
      values = ["10.10.50.121", ]
    },
    {
      # Kube Ingress K8S-SC-LOCAL
      name   = "vn-sc-ing-local",
      values = ["10.10.50.145", ]
    },
    {
      # Kube Ingress K8S-ST-BACKUP
      name   = "vn-st-ing-backup",
      values = ["10.10.50.137", ]
    },
    {
      # HAP SC LOCAL
      name   = "vn-sc-hap-local",
      values = ["10.10.50.69", ]
    },

    ###########################################
    ############### WAN MAPPING ###############
    {
      # WAN LUMPROD
      name   = "vn-sc-wan-lumprod",
      values = ["202.78.231.54", ]
    },
    {
      # WAN SWARM SC LOCAL
      name   = "vn-sc-wan-swlocal",
      values = ["202.78.231.51", ]
    },
    {
      # WAN K8S SC LOCAL
      name   = "vn-sc-wan-local",
      values = ["202.78.231.34", ]
    },

    ###########################################
    ############### EXT MAPPING ###############
    {
      name   = "d1aof1lwumql9k",
      type   = "CNAME"
      values = ["d1aof1lwumql9k.cloudfront.net", ]
    },
    {
      # Collect Autotest Report
      name   = "test-reports",
      values = ["10.10.50.160", ]
    },
    {
      # NATS on LUMPROD
      name   = "nats",
      values = ["10.10.50.122", ]
    },
    {
      # Public ALL
      name   = "vn-sc-all-lumprod",
      values = ["202.78.231.48", ]
    }
  ]

  #
  "vivadzo.com" = [
    {
      # Wildcard mapping
      name   = "*",
      values = ["10.10.50.145", ]
    },
  ]
}


cluster_cname_records = {
  "lumigame.com" = [
    {
      # 10.10.50.121 - K3S LUMPROD 
      canonical_name = "vn-sc-ing-lumprod.lumigame.com"
      cname_records = [
        "gitgd",
        "git21",
        "argocd",
        "npm-k3s",
        "vault",
        "hub-k3s",
        "logs",
        "opsi",
        "trivy",
        "portainer",
        "longhorn",
        "hub-main",
        "hub-bk",
        "jaeger-elasticsearch-k3s",
        "jaeger-k3s",
        "jaeger",
        "grafana",
        "rocketchat",
        "penpot",
        "vn-lu-ing-k3slocal",
        "openproject",
        "nui",
        "sentry-k8s",
        "deployapi-k3s",
        "deploy-test",
        "n8n-test",
      ]
    },
    {
      # 10.10.50.145 - K8S SC LOCAL
      canonical_name = "vn-sc-ing-local.lumigame.com"
      cname_records = [
        "deployapi-k8s",
        "ing-stat",
      ]
    },
    {
      # 10.10.50.137 - K3S ST BACKUP
      canonical_name = "vn-st-ing-backup.lumigame.com"
      cname_records = [
        "s3-api",
      ]
    },
    {
      # 10.10.50.69 - HAP SC LOCAL
      canonical_name = "vn-sc-hap-local.lumigame.com"
      cname_records = [
        "haproxy",
        "sonarqube",
        "rocketor-api",
        "plane",
        "sentry",
      ]
    },

    {
      # 202.78.231.54 - WAN LUMPROD
      canonical_name = "vn-sc-wan-lumprod.lumigame.com"
      cname_records = [
        "hub",
        "hubbk",
        "npm",
        "rancher",
        "deploy",
      ]
    },
    # {
    #   # 202.78.231.51 - WAN SWARM SC LOCAL
    #   canonical_name = "vn-sc-wan-swlocal.lumigame.com",
    #   # cname_records = [
    #   #   "sentry",
    #   # ]
    # },
    {
      # 202.78.231.34 - WAN K8S SC LOCAL
      canonical_name = "vn-sc-wan-local.lumigame.com",
      cname_records = [
        "l1-proxy1",
        "l1-proxy2",
        "l1-proxy3",
        "admin",
        "l1-admin1",
        "l1-admin2",
        "l1-admin3",
        "l1-proxy",
        "l1-client",
        "l1-guide",
        "l1-guide-1",
        "l1-guide-2",
        "l1-guide-3",
        "gamelobby-simulator",
        "l1-glbs1",
        "l1-glbs2",
        "l1-glbs3",
        "result",
        "l1-result1",
        "l1-result2",
        "l1-result3",
        "l1-mini1",
        "l1-mini2",
        "l1-mini3",
        "l1-mini",
        "l1-seal-live-page-client-demo",
        "l1-seal-live-page-client-demo1",
        "l1-seal-live-page-client-demo2",
        "l1-sedie-client-demo1",
        "l1-gw",
        "l1-gw1",
        "l1-gw2",
        "l1-gw3",
        "owapi-simulator",
        "l1-ows1",
        "l1-ows2",
        "l1-ows3",
        "l2-admin",
        "l2-admin1",
        "l2-admin2",
        "l2-proxy",
        "l2-proxy1",
        "l2-proxy2",
        "l2-keno",
        "l2-keno1",
        "l2-keno2",
        "l2-m",
        "l2-m1",
        "l2-m2",
        "l2-glbs",
        "l2-glbs1",
        "l2-glbs2",
        "l2-mini",
        "l2-mini1",
        "l2-mini2",
        "l2-ows",
        "l2-ows1",
        "l2-ows2",
        "l2-seal-live-page-client-demo",
        "l2-seal-live-page-client-demo1",
        "l2-seal-live-page-client-demo2",
        "l2-sedie-client-demo",
        "l2-sedie-client-demo1",
        "l2-sedie-client-demo2",
        "l2-gw",
        "l2-gw1",
        "l2-gw2",
        "l2-api",
        "l2-api1",
        "l2-api2",
        "l2-games",
        "l2-games1",
        "l2-games2",
        "api",
        "l1-api1",
        "l1-api2",
        "l1-api3",
        "games",
        "l1-games1",
        "l1-games2",
        "l1-games3",
        "bots",
        "l1-seal-hot-league-wall-client-demo1",
        "l1-standalone-live-page-local1",
      ]
    },
    {
      # 202.78.231.54 - WAN LUMPROD
      canonical_name = "vn-sc-all-lumprod.lumigame.com"
      cname_records = [
        "n8n",
      ]
    },
  ],

  # "luminetsoft.com" = [
  #   {
  #     # 10.10.50.121 - Kube Ingress K3S-LUMPROD
  #     canonical_name = "vn-sc-ing-lumprod.luminetsoft.com"
  #     cname_records = [
  #       "trivy",
  #       "portainer",
  #       "deployapi-k3s"
  #     ]
  #   },

  #   {
  #     # 202.78.231.54 - WAN LUMPROD
  #     canonical_name = "vn-sc-wan-lumprod.luminetsoft.com",
  #     cname_records = [
  #       "hub",
  #       "hubbk"
  #     ]
  #   },
  #   {
  #     # 202.78.231.51 - WAN SWARM SC LOCAL
  #     canonical_name = "vn-sc-wan-swlocal.luminetsoft.com",
  #     cname_records = [
  #       "bots",
  #       "chinese-poker",
  #       "whoami"
  #     ]
  #   }
  # ]
}

