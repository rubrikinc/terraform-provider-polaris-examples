run "no_description" {
  variables {
    name = "No Description Role"
    permissions = [
      {
        operation = "VIEW_ROLE"
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
    condition     = polaris_custom_role.role.name == "No Description Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = polaris_custom_role.role.description == ""
    error_message = "Custom role description should be empty when not provided."
  }

  assert {
    condition     = output.role_id != ""
    error_message = "Role ID output should not be empty."
  }
}
