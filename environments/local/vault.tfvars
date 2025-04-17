################ CONSTANT VARIABLE ################
# gitlab_domain               = "gitlab.nexdev.net"
env           = "local"
vault_address = "https://vault.nexdev.net"

CIDR_OFFICE                 = ["10.0.0.0/8"]
application_aws_assume_role = "arn:aws:iam::584102114761:role/lumi-local-vault-role-v1" #required


###########
########### mount
vault_mount = [
  {
    "path" : "nexops",
    "type" : "kv-v2"
  },
  {
    "path" : "pontus",
    "type" : "kv-v2"
  },
  {
    "path" : "rome",
    "type" : "kv-v2"
  },
  {
    "path" : "olympus",
    "type" : "kv-v2"
  },
  {
    "path" : "nexus",
    "type" : "kv-v2"
  },

]
########### Policy
polices = [
  ############## Automation / Tools
  {
    policy_name     = "prometheus",
    policy_path     = "tools",
    policy_template = "prometheus-policy",
  },
  {
    policy_name     = "raft-snapshot",
    policy_path     = "tools",
    policy_template = "raft-snapshot",
  },
  {
    policy_name     = "cert-reader",
    policy_path     = "tools",
    policy_template = "cert-reader",
  },
  {
    policy_name     = "cert-updater",
    policy_path     = "tools",
    policy_template = "cert-updater",
  },
  {
    policy_name     = "aws-local-cert-challenger",
    policy_path     = "tools",
    policy_template = "aws-local-cert-challenger",
  },

]
########### ROLE for System/App
roles = [
  {
    "role_name" : "p-mssql-olympus",
    "policy_path" : "dba/local",
    "policy_template" : "p-mssql-olympus",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "p-mssql-rome",
    "policy_path" : "dba/local",
    "policy_template" : "p-mssql-rome",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "p-mssql-legion",
    "policy_path" : "dba/local",
    "policy_template" : "p-mssql-legion",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "p-mssql-wabi",
    "policy_path" : "dba/local",
    "policy_template" : "p-mssql-wabi",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "dev-admin",
    "policy_path" : "dba/local",
    "policy_template" : "dev-admin",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "p-mssql-nexus",
    "policy_path" : "dba/local",
    "policy_template" : "p-mssql-nexus",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  },
  {
    "role_name" : "nexops-sample",
    "policy_path" : "tools",
    "policy_template" : "prometheus-policy",
    # "bound_cidrs" : [
    #   "10.17.200.0/24",
    #   "10.18.200.0/24",
    #   "10.19.10.0/24"
    # ]
  }

]


########### AUTH ROLE for Kubernetes auth method ############
kube_auth_backends = [
  {
    path = "kubernetes"
    roles = [
      {
        role_name    = "vault-snapshot"
        sa_name      = ["vault-snapshot", ]
        sa_namespace = ["vault", ]
        policies     = ["raft-snapshot", ]
      },
      {
        role_name    = "cert-reader"
        sa_name      = ["vault-cert-injector", ]
        sa_namespace = ["haproxy-ingress", ]
        policies     = ["cert-reader", ]
      },
      {
        role_name    = "cert-updater"
        sa_name      = ["cert-updater-starix-nexprod", ]
        sa_namespace = ["cert-manager", ]
        policies     = ["cert-updater", ]
      },
      {
        role_name    = "aws-local-cert-challenger"
        sa_name      = ["cert-manager-starix-nexprod", ]
        sa_namespace = ["cert-manager", ]
        policies     = ["aws-local-cert-challenger", ]
      },
    ]
  },
  {
    path = "kubernetes-st-backup"
    roles = [
      {
        role_name    = "cert-reader"
        sa_name      = ["vault-cert-injector", ]
        sa_namespace = ["haproxy-ingress", ]
        policies     = ["cert-reader", ]
      },
    ]
  },
  {
    path = "kubernetes-st-local"
    roles = [
      {
        role_name    = "cert-reader"
        sa_name      = ["vault-cert-injector", ]
        sa_namespace = ["haproxy-ingress", ]
        policies     = ["cert-reader", ]
      },
    ]
  },
  {
    path = "kubernetes-sc-local"
    roles = [
      {
        role_name    = "cert-reader"
        sa_name      = ["vault-cert-injector", ]
        sa_namespace = ["haproxy-ingress", ]
        policies     = ["cert-reader", ]
      },
    ]
  },
  {
    path = "kubernetes-sc-lumprod"
    roles = [
      {
        role_name    = "cert-reader"
        sa_name      = ["vault-cert-injector", ]
        sa_namespace = ["haproxy-ingress", ]
        policies     = ["cert-reader", ]
      },
    ]
  },
]


########### AWS role base access management ############
aws_secret_backend = [
  # {
  #   backend = "aws_local"
  #   roles = [
  #     {
  #       name                 = "route53-dns-challenge"
  #       credential_type      = "assumed_role"
  #       policy_document_file = "dns-challenge-lumigame-com.json"
  #     }
  #   ]
  # },
]



#####################################
vault_team = [
  "nexops",
  "pontus",
  "rome",
  "olympus",
  "nexus",
  "legion",
]

## Vault Admin Users
###
vault_admin_users = [
  "troy.vo",
  "ken.nguyen",
  "josh.tran",
  "dennis.le",
  "jacob.phan",
  "sol.le",
]
### ALL Vault Users
vault_users = [
  {
    "name" : "troy.vo",
    "team" : "nexops",
  },
  {
    "name" : "ken.nguyen",
    "team" : "nexops",
  },
  {
    "name" : "dennis.le",
    "team" : "nexops",
  },
  {
    "name" : "josh.tran",
    "team" : "nexops",
  },
  #### DBA
  {
    "name" : "lukas.luu",
    "team" : "pontus",
  },
  {
    "name" : "patrick.pham",
    "team" : "pontus",
  },
  {
    "name" : "sol.le",
    "team" : "pontus",
  },
  {
    "name" : "brice.nguyen",
    "team" : "pontus",
  },
  {
    "name" : "evan.trinh",
    "team" : "pontus",
  },
  {
    "name" : "daniel.truong",
    "team" : "pontus",
  },
  {
    "name" : "nexops.test",
    "team" : "pontus",
  },
  #### DEV
  {
    "name" : "jacob.phan",
    "team" : "olympus",
  },
  {
    "name" : "ethan.nguyen",
    "team" : "rome",
  },
  {
    "name" : "kos.nguyen",
    "team" : "legion",
  },
]

vault_users_readonly = []

############## Demo 
vault_generic_secret = [
  {
    "path" : "rome/alpha/api_1",
    "username" : "alpha1",
    "password" : "y7changeme",
  },
  {
    "path" : "olympus/setle/api_1",
    "username" : "setle1",
    "password" : "changeme",
  },
  ###Automation & tools
  {
    "path" : "nexops/automation/ansible/apitest",
    "username" : "ansible",
    "password" : "changeme",
  },
  {
    "path" : "nexops/cloud/aws/apitest",
    "username" : "aws",
    "password" : "changeme",
  },
]

################ AUDIT DEVICE ################
audit_devices = [
  {
    type = "file"
    options = {
      file_path = "stdout"
    }
  },
  {
    type = "socket"
    options = {
      address              = "logstash.nexdev.net:30064"
      socket_type          = "tcp"
      elide_list_responses = "true"
      description          = "logstash socket"
    }
  }
]

