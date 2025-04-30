# Example showing how to create a new RSC user.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=1.1.0-beta.7"
    }
  }
}

variable "role_name" {
  type        =  string
  description = "Name of the role to assign to the user."
  default     = "Administrator"
}

variable "user_email" {
  type        = string
  description = "Email address of the user."
}

provider "polaris" {}

data "polaris_role" "admin" {
  name = var.role_name
}

resource "polaris_user" "admin" {
  email = var.user_email

  role_ids = [
    data.polaris_role.admin.id
  ]
}
