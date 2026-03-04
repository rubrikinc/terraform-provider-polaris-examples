run "no_assignments" {
  variables {
    name = "Unassigned Role"
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
    condition     = length(output.user_assignment_ids) == 0
    error_message = "User assignment IDs should be empty when no user_ids are provided."
  }

  assert {
    condition     = length(output.sso_group_assignment_ids) == 0
    error_message = "SSO group assignment IDs should be empty when no sso_group_ids are provided."
  }
}
