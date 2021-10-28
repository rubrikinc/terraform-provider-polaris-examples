# Point Terraform to the Polaris provider.
terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
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

# Point the provider to the Polaris service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP service account key file to Polaris.
resource "polaris_gcp_service_account" "default" {
  credentials = var.gcp_credentials
}
