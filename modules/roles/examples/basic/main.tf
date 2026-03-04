provider "polaris" {}

module "compliance_auditor" {
  source = "../.."

  name        = "Compliance Auditor Role"
  description = "Basic custom role for compliance auditing"

  permissions = [
    {
      operation = "EXPORT_DATA_CLASS_GLOBAL"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
    {
      operation = "VIEW_DATA_CLASS_GLOBAL"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
  ]
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.compliance_auditor.role_id
}
