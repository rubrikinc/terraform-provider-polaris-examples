# Example showing how to add a custom role to RSC from a template.
#
# The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

provider "polaris" {}

data "polaris_role_template" "compliance_auditor" {
  name = "Compliance Auditor"
}

resource "polaris_custom_role" "compliance_auditor" {
  name        = "Compliance Auditor Role"
  description = "Based on the ${data.polaris_role_template.compliance_auditor.name} role template"

  dynamic "permission" {
    for_each = data.polaris_role_template.compliance_auditor.permission
    content {
      operation = permission.value["operation"]

      dynamic "hierarchy" {
        for_each = permission.value["hierarchy"]
        content {
          snappable_type = hierarchy.value["snappable_type"]
          object_ids     = hierarchy.value["object_ids"]
        }
      }
    }
  }
}
