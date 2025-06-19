# Example showing how to onboard a GCP project to RSC.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
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
