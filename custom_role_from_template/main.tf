# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "~>0.5.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

data "polaris_role_template" "compliance_auditor" {
  name = "Compliance Auditor"
}

# Add custom role based on a role template to RSC.
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
