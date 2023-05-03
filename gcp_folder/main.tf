# Example of how to add all GCP projects under a specific GCP folder.

# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

variable "gcp_folder" {
  type        = string
  description = "GCP folder id."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

data "google_projects" "default" {
  filter = "parent.id:${var.gcp_folder}"
}

# Add the GCP project to RSC.
resource "polaris_gcp_project" "default" {
  for_each    = toset([for v in data.google_projects.default.projects : v.project_id])
  credentials = var.gcp_credentials
  project     = each.key

  cloud_native_protection {
  }
}
