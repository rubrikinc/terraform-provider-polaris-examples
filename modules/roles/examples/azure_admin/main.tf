terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=9.0.0"
    }
  }
}

provider "polaris" {}

module "azure_admin" {
  source = "../.."

  name        = "Azure Admin Role"
  description = "Admin role for managing Azure workloads"

  permissions = [
    {
      operation = "MANAGE_PROTECTION_AZURE"
      hierarchy = [
        {
          snappable_type = "AzureNativeVm"
          object_ids     = ["GlobalResource"]
        },
        {
          snappable_type = "AzureNativeManagedDisk"
          object_ids     = ["GlobalResource"]
        },
      ]
    },
    {
      operation = "VIEW_INVENTORY_AZURE"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        },
      ]
    },
    {
      operation = "EXPORT_SNAPSHOTS_AZURE"
      hierarchy = [
        {
          snappable_type = "AzureNativeVm"
          object_ids     = ["GlobalResource"]
        },
      ]
    },
  ]
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.azure_admin.role_id
}
