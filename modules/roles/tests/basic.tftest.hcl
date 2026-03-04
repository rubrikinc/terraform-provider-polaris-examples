run "custom_role" {
  variables {
    name        = "Test Role"
    description = "Test role for basic integration test"
    permissions = [
      {
        operation = "VIEW_ROLE"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      }
    ]
  }

  assert {
    condition     = polaris_custom_role.role.name == "Test Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = polaris_custom_role.role.description == "Test role for basic integration test"
    error_message = "Custom role description does not match input variable."
  }

  assert {
    condition     = output.role_name == "Test Role"
    error_message = "Role name output does not match input variable."
  }
}
