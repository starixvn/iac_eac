#####
cluster_org = "starix"
cluster_env = "kbt"

# Access Controll Management
clusters_ac = {
  "sc-uat" = { # Cluster on Rancher
    name = "sc-uat"
    projects = {
      "pentagon" = {
        name        = "pentagon"
        description = "project for Pentagon Teams"
        roles = {
          "ro" = { # Project ReadOnly Member
            group_members = []
            members       = []
          }
          "pm" = { # Project Member
            group_members = [
              "pentagon-uat",
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
      "troy.vo",
    ]
  }

  "pentagon-uat" = {
    rancher_admin = false
    members = [
      "alice.le",
      "billy.bui",
      "brian.nguyen",
      "conall.nguyen",
      "david.tran",
      "dory.vu",
      "draco.nguyen",
      "drake.doi",
      "dwight.tran",
      "elias.ngo",
      "elio.nguyen",
      "elton.ton",
      "emi.tu",
      "eros.pham",
      "esther.nguyen",
      "faisall.tran",
      "jasmine.le",
      "lucian.vo",
      "nancy.dao",
      "quinn.vo",
      "ricky.nguyen",
      "rita.bui",
      "roger.le",
      "scofield.huynh",
      "theresa.le",
      "tracy.hoang",
      "vivian.nguyen",
      "cruz.huynh",
      "wynn.ton",
      "nexops.test",
    ]
  }

  "pentagon-prod" = {
    rancher_admin = false
    members = [
      "billy.bui",
      "conall.nguyen",
      "david.tran",
      "drake.doi",
      "dwight.tran",
      "elton.ton",
      "eros.pham",
      "quinn.vo",
      "ricky.nguyen",
      "roger.le",
      "scofield.huynh",
      "vivian.nguyen",
    ]
  }

}
