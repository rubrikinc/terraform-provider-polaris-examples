terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=9.0.0"
    }
  }
}

provider "polaris" {}

variable "sso_group_name" {
  description = "Name of the SSO group to assign the role to."
  type        = string
}

data "polaris_sso_group" "group" {
  name = var.sso_group_name
}

module "sso_viewer_role" {
  source = "../.."

  name        = "SSO Viewer Role"
  description = "Read-only role assigned to an SSO group"

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

  sso_group_ids = [data.polaris_sso_group.group.id]
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.sso_viewer_role.role_id
}

output "sso_group_assignment_ids" {
  description = "Map of SSO group IDs to assignment IDs."
  value       = module.sso_viewer_role.sso_group_assignment_ids
}
