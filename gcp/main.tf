# Example showing how to onboard a GCP project to RSC.
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

variable "project" {
  type        = string
  description = "GCP project id."
}

provider "polaris" {}

resource "polaris_gcp_project" "default" {
  credentials = var.gcp_credentials
  project     = var.project

  cloud_native_protection {
  }
}
