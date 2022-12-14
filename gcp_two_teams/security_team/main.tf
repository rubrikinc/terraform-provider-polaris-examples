# Point Terraform to the RSC provider.
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
  description = "Path to the RSC service account file."
}

variable "gcp_credentials" {
  type        = string
  description = "Path to the GCP service account key file."
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the GCP service account key file to RSC.
resource "polaris_gcp_service_account" "default" {
  credentials = var.gcp_credentials
}
