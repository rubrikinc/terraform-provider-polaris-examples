# Example showing how to assign a role to an RSC user.
#
# Note, when using multiple polaris_role_assignment resources to assign roles
# to the same user or SSO group, there is a risk for a race condition when the
# resources are destroyed. This can result in roles still being assigned to the
# user or SSO group. The race condition can be avoided by either assigning all
# roles to the user using a single polaris_role_assignment resource or by using
# the depends_on field to make sure that the resources are destroyed in a serial
# fashion.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.1.0"
    }
  }
}

provider "polaris" {}

variable "role_name" {
  type        = string
  description = "Name of the role to assign to the user."
  default     = "administrator"
}

variable "user_email" {
  type        = string
  description = "Email address of the user to assign the role to."
}

data "polaris_role" "role" {
  name = var.role_name
}

data "polaris_user" "user" {
  email = var.user_email
}

resource "polaris_role_assignment" "user" {
  user_id = data.polaris_user.user.id

  role_ids = [
    data.polaris_role.role.id,
  ]
}
