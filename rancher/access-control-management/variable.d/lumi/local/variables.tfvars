##########
cluster_org = "lumi"
cluster_env = "local"


# Access Controll Management
clusters_ac = {
  "sc-local" = {
    name = "sc-local"
    projects = {
      "pentagon" = {
        name        = "pentagon"
        description = "project for Pentagon Teams"
        roles = {
          "ro" = {
            # Project ReadOnly Member
            group_members = []
            members       = []
          }
          "pm" = {
            # Project Member
            group_members = [
              "pentagon",
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
      "dennis.le",
      "ken.nguyen",
      "troy.vo",
    ]
  }

  "pentagon" = {
    members = [
      "billy.bui",
      "bill.nguyen",
      "brian.nguyen",
      "conall.nguyen",
      "draco.nguyen",
      "drake.doi",
      "dwight.tran",
      "elias.ngo",
      "elton.ton",
      "esther.nguyen",
      "george.phung",
      "lucian.vo",
      "ricky.nguyen",
      "roger.le",
      "vivian.nguyen",
      "zephyr.nguyen",
      "cruz.huynh",
      "wynn.ton",
      "james.nguyen"
    ]
  }

}
