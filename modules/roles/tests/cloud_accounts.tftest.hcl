run "cloud_account_permissions" {
  variables {
    name        = "Cloud Account Admin"
    description = "Role for managing cloud accounts across all providers"
    permissions = [
      {
        operation = "VIEW_AWS_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "ADD_AWS_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_AZURE_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "ADD_AZURE_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_GCP_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "ADD_GCP_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_OCI_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "ADD_OCI_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "ADD_AWS_ROLE_CHAINING_CLOUD_ACCOUNT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["AWSNATIVE_ROOT"]
          }
        ]
      },
    ]
  }

  assert {
    condition     = polaris_custom_role.role.name == "Cloud Account Admin"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 9
    error_message = "Expected 9 permissions on the custom role."
  }

  assert {
    condition     = output.role_id != ""
    error_message = "Role ID output should not be empty."
  }
}
