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

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

variable "project" {
  type        = string
  description = "GCP project id."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP project to RSC.
resource "polaris_gcp_project" "default" {
  credentials = var.gcp_credentials
  project     = var.project

  cloud_native_protection {
  }
}
