env = "testlab"
vault_address = "http://10.70.70.142:8200"
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
    "path" : "starix_db",
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
    ## Users / Team
   
    ############## Automation / Tools

]
########### ROLE for System/App
roles = [
    
]

############## Demo 
vault_generic_secret = [
    {
    "path" : "pontus/database/mysql/dbtest",
    "username" : "vaultuser",
    "password" : "pass12345",
    },
    {
    "path" : "pontus/database/mssql/dbtest",
    "username" : "vaultuser_mssql",
    "password" : "changeme",
    },
    {
    "path" : "rome/alpha/y7/y7apitest",
    "username" : "y7starixapitest",
    "password" : "y7changeme",
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
    "ken.nguyen"
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
      #### DBA
      {
        "name" : "lukas.luu",
        "team" : "pontus",
      },
      {
        "name" : "patrick",
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

vault_users_readonly = [
      {
        "name" : "charlie",
        "team" : "olympus",
      },
      {
        "name" : "eva",
        "team" : "rome",
      },
      {
        "name" : "brice",
        "team" : "pontus",
      },
    ]
