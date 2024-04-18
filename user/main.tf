# Example showing how to create a new RSC user.
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

variable "user_email" {
  type        = string
  description = "User email address."
}

provider "polaris" {}

data "polaris_role" "admin" {
  name = "Administrator"
}

resource "polaris_user" "admin" {
  email = var.user_email
  role_ids = [
    data.polaris_role.admin.id
  ]
}
