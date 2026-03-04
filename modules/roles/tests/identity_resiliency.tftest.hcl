run "identity_resiliency_permissions" {
  variables {
    name        = "Identity Resiliency Role"
    description = "Role for identity resiliency management"
    permissions = [
      {
        operation = "VIEW_IDENTITY_RESILIENCY"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_IDENTITY_RESILIENCY"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "REMEDIATE_IDENTITY_RESILIENCY_VIOLATIONS"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
    ]
  }

  assert {
    condition     = polaris_custom_role.role.name == "Identity Resiliency Role"
    error_message = "Custom role name does not match input variable."
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
