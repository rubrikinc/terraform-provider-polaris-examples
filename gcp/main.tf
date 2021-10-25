# Point Terraform to the Polaris provider.
terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = "~>0.3.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Account name or path to the Polaris service account file."
}

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

variable "project" {
  type        = string
  description = "GCP project id."
}

# Point the provider to the Polaris service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP project to Polaris.
resource "polaris_gcp_project" "default" {
  credentials = var.gcp_credentials
  project     = var.project

  cloud_native_protection {
  }
}
