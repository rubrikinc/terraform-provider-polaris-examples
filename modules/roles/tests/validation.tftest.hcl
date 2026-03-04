run "empty_name" {
  command = plan

  variables {
    name = ""
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

  expect_failures = [
    var.name,
  ]
}

run "empty_permissions" {
  command = plan

  variables {
    name        = "Empty Permissions Role"
    permissions = []
  }

  expect_failures = [
    var.permissions,
  ]
}
