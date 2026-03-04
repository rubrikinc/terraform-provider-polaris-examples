run "cluster_scoped_permissions" {
  variables {
    name        = "Cluster Admin Role"
    description = "Role with cluster-scoped permissions"
    permissions = [
      {
        operation = "VIEW_CLUSTER"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT"]
          }
        ]
      },
      {
        operation = "UPGRADE_CLUSTER"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT"]
          }
        ]
      },
      {
        operation = "MANAGE_CLUSTER_SETTINGS"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT"]
          }
        ]
      },
      {
        operation = "ACCESS_CDM_CLUSTER"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT"]
          }
        ]
      },
    ]
  }

  assert {
    condition     = polaris_custom_role.role.name == "Cluster Admin Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 4
    error_message = "Expected 4 permissions on the custom role."
  }

  assert {
    condition     = output.role_id != ""
    error_message = "Role ID output should not be empty."
  }
}
