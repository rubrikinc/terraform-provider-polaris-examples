terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=9.0.0"
    }
  }
}

provider "polaris" {}

variable "template_name" {
  description = "Name of the role template to use."
  type        = string
  default     = "Compliance Auditor"
}

data "polaris_role_template" "template" {
  name = var.template_name
}

resource "polaris_custom_role" "from_template" {
  name        = "${var.template_name} Role"
  description = "Based on the ${data.polaris_role_template.template.name} role template"

  dynamic "permission" {
    for_each = data.polaris_role_template.template.permission
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

output "role_id" {
  description = "The ID of the created custom role."
  value       = polaris_custom_role.from_template.id
}
