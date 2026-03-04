run "multiple_hierarchies" {
  variables {
    name = "Multi-Hierarchy Role"
    permissions = [
      {
        operation = "USE_AS_REPLICATION_TARGET"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT", "CROSS_ACCOUNT_CLUSTER_ROOT"]
          }
        ]
      },
    ]
  }

  assert {
    condition     = polaris_custom_role.role.name == "Multi-Hierarchy Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 1
    error_message = "Expected 1 permission on the custom role."
  }

  assert {
    condition     = output.role_name == "Multi-Hierarchy Role"
    error_message = "Role name output does not match input variable."
  }
}
