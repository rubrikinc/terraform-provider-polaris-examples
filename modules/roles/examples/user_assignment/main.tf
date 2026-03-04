provider "polaris" {}

variable "user_email" {
  description = "Email address of the user to assign the role to."
  type        = string
}

data "polaris_user" "user" {
  email = var.user_email
}

module "viewer_role" {
  source = "../.."

  name        = "Viewer Role"
  description = "Read-only role assigned to a user"

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

  user_ids = [data.polaris_user.user.id]
}

output "role_id" {
  description = "The ID of the created custom role."
  value       = module.viewer_role.role_id
}

output "user_assignment_ids" {
  description = "Map of user IDs to assignment IDs."
  value       = module.viewer_role.user_assignment_ids
}
