terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
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

data "polaris_role" "compliance_auditor" {
  name = "Compliance Auditor Role"
}

# Assign the role to a user.
resource "polaris_role_assignment" "compliance_auditor" {
  role_id    = data.polaris_role.compliance_auditor.id
  user_email = var.user_email
}
