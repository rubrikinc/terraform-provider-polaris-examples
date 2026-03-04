run "integration_permissions" {
  variables {
    name        = "Integration Admin Role"
    description = "Role for managing third-party integrations"
    permissions = [
      {
        operation = "VIEW_SERVICENOW_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_SERVICENOW_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_OKTA_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_OKTA_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_ZSCALER_DLP_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_ZSCALER_DLP_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_DSPM_INTEGRATIONS"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_DSPM_INTEGRATIONS"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_GOOGLE_SECOPS_INTEGRATION"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "MANAGE_GOOGLE_SECOPS_INTEGRATION"
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
    condition     = polaris_custom_role.role.name == "Integration Admin Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 10
    error_message = "Expected 10 permissions on the custom role."
  }

  assert {
    condition     = output.role_id != ""
    error_message = "Role ID output should not be empty."
  }
}
