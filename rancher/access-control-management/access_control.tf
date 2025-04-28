# Global RoleBinding
resource "rancher2_global_role_binding" "global_rolebindings" {
  for_each       = { for entry in local.global_rolebindings : "${entry.role_binding_name}" => entry }
  name           = each.key
  global_role_id = each.value.role_template_id
  user_id        = rancher2_user.users["${each.value.username}"].id
}

# Cluster RoleBinding
resource "rancher2_cluster_role_template_binding" "cluster_rolebindings" {
  for_each         = { for entry in local.cluster_rolebindings : "${entry.role_binding_name}" => entry }
  name             = each.key
  cluster_id       = data.rancher2_cluster.clusters["${each.value.cluster_name}"].id
  role_template_id = each.value.role_template_id
  user_id          = rancher2_user.users["${each.value.username}"].id
}

# Project RoleBinding
resource "rancher2_project_role_template_binding" "project_rolebindings" {
  for_each         = { for entry in local.project_rolebindings : "${entry.role_binding_name}" => entry }
  name             = each.key
  project_id       = rancher2_project.projects["${each.value.project_tname}"].id
  role_template_id = each.value.role_template_id
  user_id          = rancher2_user.users["${each.value.username}"].id
}
