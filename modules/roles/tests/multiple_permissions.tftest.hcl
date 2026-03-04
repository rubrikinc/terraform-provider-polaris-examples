run "multiple_permissions" {
  variables {
    name        = "Multi-Permission Role"
    description = "Role with multiple permissions across different scopes"
    permissions = [
      {
        operation = "EXPORT_DATA_CLASS_GLOBAL"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_DATA_CLASS_GLOBAL"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_CLUSTER"
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
    condition     = polaris_custom_role.role.name == "Multi-Permission Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = polaris_custom_role.role.description == "Role with multiple permissions across different scopes"
    error_message = "Custom role description does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 3
    error_message = "Expected 3 permissions on the custom role."
  }

  assert {
    condition     = output.role_id != ""
    error_message = "Role ID output should not be empty."
  }
}
