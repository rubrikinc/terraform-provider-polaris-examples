# Example showing how to onboard the GCP service account to RSC, independent
# of a GCP project.
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

provider "polaris" {}

resource "polaris_gcp_service_account" "default" {
  credentials = var.gcp_credentials
}
