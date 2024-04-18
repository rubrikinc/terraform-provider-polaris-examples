# Example showing how to assign a role to an RSC user.
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

data "polaris_role" "compliance_auditor" {
  name = "Compliance Auditor Role"
}

resource "polaris_role_assignment" "compliance_auditor" {
  role_id    = data.polaris_role.compliance_auditor.id
  user_email = var.user_email
}
