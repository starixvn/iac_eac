####
cluster_org = "starix"
cluster_env = "sit"

# Access Controll Management
clusters_ac = {
  "sc-sit" = { # Cluster on Rancher
    projects = {
      "pentagon" = {
        description = "project for Pentagon Teams"
        roles = {
          "ro" = { # Project ReadOnly Member
            group_members = []
            members       = []
          }
          "pm" = { # Project Member
            group_members = [
              "pentagon-sit",
            ]
            members = []
          }
        }
      }
      "ops" = {
        name        = "ops"
        description = "Project for Ops Services"
        roles       = {}
      }
    }
  }
}


user_groups = {
  "nexops" = {
    rancher_admin = true
    members = [
      "josh.tran",
      "larry.tran",
    ]
  }

  "pentagon-sit" = {
    rancher_admin = false
    members = [
      "nexops.test",
    ]
  }

}

# REQUIRED VARIABLE SET [rancher_cred]
vault_secrets = {
  rancher_cred = {
    mount = "nexops"
    path  = "automation/rancher/st/sit/nexops"
  }
}
