# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "~>0.6.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "user_email" {
  type        = string
  description = "User email address."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

data "polaris_role" "admin" {
  name = "Administrator"
}

resource "polaris_user" "admin" {
  email    = var.user_email
  role_ids = [
    data.polaris_role.admin.id
  ]
}
