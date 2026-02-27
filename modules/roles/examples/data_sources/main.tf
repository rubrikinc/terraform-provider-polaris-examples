terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=9.0.0"
    }
  }
}

provider "polaris" {}

data "polaris_operations" "all" {}

data "polaris_workloads" "all" {}

locals {
  # Filter operations to only include VIEW operations.
  view_operations = [for op in data.polaris_operations.all.operations : op if startswith(op, "VIEW")]
}

module "viewer_role" {
  source = "../.."

  name        = "Viewer Role"
  description = "Custom role built using operations and workloads data sources"

  permissions = [
    for operation in local.view_operations : {
      operation = operation
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    }
  ]
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.viewer_role.role_id
}
