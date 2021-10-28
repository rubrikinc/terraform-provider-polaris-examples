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
  description = "Account name or path to Polaris service account file."
}

variable "azure_credentials" {
  type        = string
  description = "Path to the Azure service principal file."
}

# Point the provider to the Polaris service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the Azure service principal to Polaris. See the main README for an
# explanation of this file.
resource "polaris_azure_service_principal" "default" {
  credentials = var.azure_credentials
}
