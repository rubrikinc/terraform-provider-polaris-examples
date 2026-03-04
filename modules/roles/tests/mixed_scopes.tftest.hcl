run "mixed_scopes" {
  variables {
    name        = "Mixed Scope Role"
    description = "Role with permissions across cluster, global, and other scopes"
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
        operation = "USE_AS_REPLICATION_TARGET"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CLUSTER_ROOT", "CROSS_ACCOUNT_CLUSTER_ROOT"]
          }
        ]
      },
      {
        operation = "VIEW_ROLE"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["GlobalResource"]
          }
        ]
      },
      {
        operation = "VIEW_CROSS_ACCOUNT_PAIR"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CROSS_ACCOUNT_PAIR_ROOT"]
          }
        ]
      },
      {
        operation = "VIEW_CHATBOT"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["CHATBOT_ROOT"]
          }
        ]
      },
      {
        operation = "SELF_SERVICE_RESTORE"
        hierarchy = [
          {
            snappable_type = "AllSubHierarchyType"
            object_ids     = ["O365_ROOT"]
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
    condition     = polaris_custom_role.role.name == "Mixed Scope Role"
    error_message = "Custom role name does not match input variable."
  }

  assert {
    condition     = length(polaris_custom_role.role.permission) == 7
    error_message = "Expected 7 permissions on the custom role."
  }

  assert {
    condition     = output.role_name == "Mixed Scope Role"
    error_message = "Role name output does not match input variable."
  }
}
