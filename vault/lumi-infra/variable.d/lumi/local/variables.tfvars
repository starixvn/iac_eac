env           = "local"
vault_address = "https://vault.lumigame.com"

CIDR_OFFICE                 = ["10.0.0.0/8"]
application_aws_assume_role = "arn:aws:iam::584102114761:role/lumi-local-vault-role-v1" #required

bound_gitlab_project_id = "2660,3061,3062"
bound_gitlab_ref        = "main,dev,local,deploy-*-local"
bound_gitlab_ref_type   = "branch,tag"

#####
########### mount
vault_mount = [
  {
    "path" : "nexops",
    "type" : "kv-v2"
  },
  {
    "path" : "pentagon",
    "type" : "kv-v2"
  },

]
########### Policy
polices = [
  ## Users / Team
  {
    "policy_name" : "lumi_dba",
    "policy_path" : "dba",
    "policy_template" : "lumi-dba-policy",
  },
  ############## System/App
  {
    "policy_name" : "service-sg",
    "policy_path" : "dba",
    "policy_template" : "sg-policy",
  },
  {
    "policy_name" : "service-vg",
    "policy_path" : "dba",
    "policy_template" : "vg-policy",
  },

  ############## Automation / Tools
  {
    "policy_name" : "prometheus",
    "policy_path" : "tools",
    "policy_template" : "prometheus-policy",
  },
  {
    "policy_name" : "raft-snapshot",
    "policy_path" : "tools",
    "policy_template" : "raft-snapshot",
  },

]
########### ROLE for System/App
roles = [
  {
    "role_name" : "service-sg",
    "policy_path" : "dba",
    "policy_template" : "sg-policy",
  },
  {
    "role_name" : "service-vg",
    "policy_path" : "dba",
    "policy_template" : "vg-policy",
  },

]


########### AUTH ROLE for Kubernetes auth method ############
kubernetes_auth_role = [
  {
    "role_name" : "vault-snapshot",
    "sa_name" : "vault-snapshot"
    "sa_namespace" : "vault",
    "policies" : ["raft-snapshot", ],
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
  "pentagon",
  "sg",
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
    "name" : "billy.bui",
    "team" : "pentagon",
  },
  #### DEV
  {
    "name" : "ricky.nguyen",
    "team" : "sg",
  },
  {
    "name" : "vivian.nguyen",
    "team" : "sg",
  },
]

vault_users_readonly = [
  {
    "name" : "david.teo",
    "team" : "sg",
  },
]

############## Demo 
vault_generic_secret = [
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
      file_path = "/vault/logs/audit.log"
    }
  },
  {
    type = "socket"
    options = {
      address     = "logstash-lumi-lumprod-logstash.logging-lumi:5064"
      socket_type = "tcp"
      description = "logstash socket"
    }
  }
]
