locals {
  clusters = flatten([
    for cluster, cluster_details in var.clusters_ac : {
      name = "${cluster}"
    }
  ])

  projects = flatten([
    for cluster, cluster_details in var.clusters_ac : [
      for project, project_details in cluster_details.projects : {
        project_tname = "${cluster}-${project}"
        project_name  = "${project}"
        cluster_name  = "${cluster}"
      }
    ]
  ])

  users_temp = flatten([
    for group, group_details in var.user_groups : [
      for member in group_details.members : {
        name          = member
        rancher_admin = lookup(group_details, "rancher_admin", false)
      }
    ]
  ])
  # Deduplicate
  unique_item_users = distinct([for item in local.users_temp : jsonencode(item)])
  users             = [for encoded_item in local.unique_item_users : jsondecode(encoded_item)]



  #######################
  ##  GLOBAL ROLE BINDING
  global_rolebindings = flatten([
    for member in local.users : {
      role_binding_name = replace("g-rbinding-${member.name}", ".", "-")
      role_template_id  = member.rancher_admin ? "admin" : "user-base"
      username          = "${member.name}"
    }
  ])


  #######################
  ##  CLUSTER ROLE BINDING
  cluster_users_temp = flatten([
    for cluster, cluster_details in var.clusters_ac : [
      for project, project_details in cluster_details.projects :
      concat(
        [
          for role, role_details in project_details.roles :
          length(role_details.group_members) > 0 ? [
            for group in role_details.group_members : [
              for member in var.user_groups["${group}"].members : {
                cluster = "${cluster}"
                name    = "${member}"
              }
            ]
          ] : []
        ],
        [
          for role, role_details in project_details.roles :
          length(role_details.members) > 0 ? [
            for member in role_details.members : {
              cluster = "${cluster}"
              name    = "${member}"
            }
          ] : []
        ]
      )
    ]
  ])
  # Deduplicate
  unique_item_cluster_users = distinct([for item in local.cluster_users_temp : jsonencode(item)])
  cluster_users             = [for encoded_item in local.unique_item_cluster_users : jsondecode(encoded_item)]

  cluster_rolebindings = flatten([
    for user in local.cluster_users : {
      role_binding_name = replace("c-rbinding-${user.cluster}-${user.name}", ".", "-")
      cluster_name      = "${user.cluster}"
      role_template_id  = rancher2_role_template.cluster_no_permission.id
      username          = "${user.name}"
    }
  ])


  #######################
  ##  PROJECT ROLE BINDING
  project_users_temp = flatten([
    for cluster, cluster_details in var.clusters_ac : [
      for project, project_details in cluster_details.projects :
      concat(
        [
          # PARSER MEMBER ON GROUP
          for role, role_details in project_details.roles :
          length(role_details.group_members) > 0 ? [
            for group in role_details.group_members : [
              for member in var.user_groups["${group}"].members : {
                cluster = "${cluster}"
                project = "${project}"
                name    = "${member}"
                role    = "${role}"
              }
            ]
          ] : []
        ],
        [
          # CONCAT MEMBER LIST
          for role, role_details in project_details.roles :
          length(role_details.members) > 0 ? [
            for member in role_details.members : {
              cluster = "${cluster}"
              project = "${project}"
              name    = "${member}"
              role    = "${role}"
            }
          ] : []
        ]
      )
    ]
  ])

  # Deduplicate
  unique_item_project_users = distinct([for item in local.project_users_temp : jsonencode(item)])
  project_users             = [for encoded_item in local.unique_item_project_users : jsondecode(encoded_item)]

  project_rolebindings = flatten([
    for user in local.project_users : {
      role_binding_name = replace("p-rbinding-${user.cluster}-${user.project}-${user.name}-${user.role}", ".", "-")
      project_tname     = "${user.cluster}-${user.project}"
      username          = "${user.name}"
      role_template_id  = user.role == "ro" ? rancher2_role_template.custom_project_readonly.id : user.role == "pm" ? rancher2_role_template.custom_project_member.id : ""
    }
  ])


}
