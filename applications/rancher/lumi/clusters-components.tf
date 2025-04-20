# Cluster definition
data "rancher2_cluster" "clusters" {
  for_each = { for entry in local.clusters : "${entry.name}" => entry }
  name     = each.key
}

# Create Project on Cluster
resource "rancher2_project" "projects" {
  for_each   = { for entry in local.projects : "${entry.project_tname}" => entry }
  name       = each.value.project_name
  cluster_id = data.rancher2_cluster.clusters["${each.value.cluster_name}"].id
  # cluster_id  = rancher2_cluster.cluster.id
}

# Create users object
resource "rancher2_user" "users" {
  for_each = { for entry in local.users : "${entry.name}" => entry }
  name     = each.key
  username = each.key
  password = var.default_passwd
  enabled  = true
  # must_change_password = false
}
