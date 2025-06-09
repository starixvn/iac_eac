env           = "klprod"
vault_address = "https://vn-st-klp-vault.byb6181.com"

application_aws_assume_role = "arn:aws:iam::584102114761:role/lumi-prod-vault-role-v1"

# 3117: https://gitlab.nexdev.net/iac/vault/dba-policy-mgmt
# 3118: https://gitlab.nexdev.net/iac/vault/infra-mgmt
bound_gitlab_project_id = "2660,3061,3062,3117,3118"
bound_gitlab_ref        = "main,klprod,deploy_*_klprod"
bound_gitlab_ref_type   = "branch,tag"

############
########### mount
vault_mount = [
  {
    path = "nexops",
    type = "kv-v2"
  },
  {
    path = "pontus",
    type = "kv-v2"
  },
  {
    path = "rome",
    type = "kv-v2"
  },
  {
    path = "olympus",
    type = "kv-v2"
  },
  {
    path = "nexus",
    type = "kv-v2"
  },

]
########### Policy
polices = [
  ############## System/App

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

]
########### ROLE for System/App
roles = []

########### AUTH ROLE for Kubernetes auth method ############
kubernetes_auth_role = [
  {
    role_name    = "vault-snapshot",
    sa_name      = "vault-snapshot",
    sa_namespace = "vault",
    policies     = ["raft-snapshot", ],
  },
]

kube_auth_backends = [
  {
    path = "kubernetes",
    roles = [
      {
        role_name    = "vault-snapshot"
        sa_name      = ["vault-snapshot", ]
        sa_namespace = ["vault", ]
        policies     = ["raft-snapshot", ]
      },
    ]
  },
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
##
vault_admin_users = [
  "troy.vo",
  "ken.nguyen",
  "josh.tran",
  "dennis.le",
]
## ALL Vault Users
vault_users = [
  {
    name = "troy.vo",
    team = "nexops",
  },
  {
    name = "ken.nguyen",
    team = "nexops",
  },
  {
    name = "dennis.le",
    team = "nexops",
  },
  {
    name = "josh.tran",
    team = "nexops",
  },
  #### DBA
  {
    name = "lukas.luu",
    team = "pontus",
  },
  {
    name = "patrick.pham",
    team = "pontus",
  },
  {
    name = "sol.le",
    team = "pontus",
  },
  {
    name = "brice.nguyen",
    team = "pontus",
  },
  {
    name = "evan.trinh",
    team = "pontus",
  },
  {
    name = "daniel.truong",
    team = "pontus",
  },
  {
    name = "dominic.dao",
    team = "pontus",
  },
  #### DEV
  {
    name = "jacob.phan",
    team = "olympus",
  },
  {
    name = "ethan.nguyen",
    team = "rome",
  },
  {
    name = "kos.nguyen",
    team = "legion",
  },
]

vault_users_readonly = []

############### Demo 
vault_generic_secret = []

# gitlab_domain               = "gitlab.nexdev.net"

################ AUDIT DEVICE ################
audit_devices = [
  {
    type = "file"
    options = {
      file_path = "stdout"
    }
  },
  # {
  #   type = "socket"
  #   options = {
  #     address              = "logstash-starix-k3sprod-logstash.logging.svc:5064"
  #     socket_type          = "tcp"
  #     elide_list_responses = "true"
  #     description          = "logstash socket"
  #   }
  # }
]
