###
rancher-url = "https://rancher.lumigame.com"


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
    rancher_admin = false
    members = [
      "nexops.test",
      "alice.le",
      "amy.vu",
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
      "george.phung",
      "james.nguyen",
      "jasmine.le",
      "justin.pham",
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
      "zephyr.nguyen",
    ]
  }

}
