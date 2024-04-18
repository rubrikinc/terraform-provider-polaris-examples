# Example showing how to onboard all GCP projects under a specific GCP folder
# to RSC.
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

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

variable "gcp_folder" {
  type        = string
  description = "GCP folder id."
}

provider "polaris" {}

data "google_projects" "default" {
  filter = "parent.id:${var.gcp_folder}"
}

resource "polaris_gcp_project" "default" {
  for_each = toset([
    for v in data.google_projects.default.projects : v.project_id
  ])

  credentials = var.gcp_credentials
  project     = each.key

  cloud_native_protection {}
}
